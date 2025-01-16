import os
import json
import socket
import uvicorn
import asyncio
import multiprocessing

from load_test import LoadTest
from config import SERVERS
from system_metrics import get_system_metrics, restart_all_containers

from pydantic import BaseModel
from typing import AsyncGenerator
from concurrent.futures import ProcessPoolExecutor

from fastapi import FastAPI, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, StreamingResponse

# Create the main FastAPI application for managing endpoints and services
app = FastAPI()

TEMPLATES = Jinja2Templates(directory="templates")

# Mount static files
app.mount("/static", StaticFiles(directory="static"), name="static")

# Configure CORS to allow access from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Calculate optimal number of worker processes
cores = multiprocessing.cpu_count()
workers = (2 * cores) + 1  # Gunicorn-style worker calculation
# Create a process pool to run load tests in parallel
process_pool = ProcessPoolExecutor(max_workers=workers)

@app.get("/selenium-hub-ip")
def get_server_ip():
    """
    Get the IP address of the host or environment variable provided.
    """
    host_ip = os.getenv("HUB_PUBLIC_IP", "IP not found")
    print(f"Public Hub IP: {host_ip}")
    return {"ip": host_ip}

@app.get("/")
async def read_root():
    """
    Render the application's index page.

    Returns:
        TemplateResponse: The index.html template
    """
    return TEMPLATES.TemplateResponse("index.html", {"request": {}})


class LoadTestInput(BaseModel):
    """
    Pydantic model to validate input for load testing
    """

    proxy: str
    org: str
    url: str
    username: str
    password: str
    sessions: int
    mode: str


def run_load_test_in_process(proxy, org, url, username, password, sessions, mode):
    """
    Execute load testing in an isolated process to prevent blocking the main thread.

    Args:
        proxy (str): Proxy server address to be used.
        sessions (int): Number of concurrent test sessions.
        mode (str): Test mode - 'conc' for concurrent or 'seq'.
        org (str): Organization name.
        url (str): PAC file URL.
        username (str): Keycloak username.
        password (str): Keycloak password.

    Returns:
        dict: Load test results or error message.
    """
    try:
        load_test = LoadTest(proxy, org, url, username, password, sessions, mode)
        return load_test.run_load_test()
    except Exception as e:
        return {"error": str(e)}


@app.post("/start-load-test")
async def start_load_test(input: LoadTestInput):
    """
    Endpoint for initiating load testing with specified parameters.

    Args:
        input (LoadTestInput): Proxy and session configuration for load test.

    Returns:
        dict: Test completion status and results.
    """
    try:
        loop = asyncio.get_event_loop()
        result = await loop.run_in_executor(
            process_pool,
            run_load_test_in_process,
            input.proxy,
            input.org,
            input.url,
            input.username,
            input.password,
            input.sessions,
            input.mode,
        )
        return {"status": "Test completed", "result": result}
    except Exception as e:
        return {"status": "error", "message": str(e)}


@app.get("/latest-report")
async def latest_load_test_report():
    """
    Retrieve the most recent load test report from the reports directory.

    Returns:
        FileResponse: Latest JSON report file
        HTTPException: 404 error if no reports are found
    """
    reports_dir = "reports"

    # Verify reports directory exists
    if not os.path.exists(reports_dir):
        raise HTTPException(status_code=404, detail="Reports directory not found")

    # Find JSON report files
    reports = [
        f
        for f in os.listdir(reports_dir)
        if f.startswith("load_test_report_") and f.endswith(".json")
    ]

    # Check if any reports exist
    if not reports:
        raise HTTPException(status_code=404, detail="No reports found")

    # Find the latest report by modification time
    latest_report = max(
        reports, key=lambda f: os.path.getmtime(os.path.join(reports_dir, f))
    )
    report_path = os.path.join(reports_dir, latest_report)

    # Ensure the report file exists
    if not os.path.exists(report_path):
        raise HTTPException(status_code=404, detail="Latest report file not found")

    # Return the report file
    return FileResponse(
        path=report_path, filename=latest_report, media_type="application/json"
    )


@app.post("/stop-test")
async def stop_test():
    """
    Restart all configured servers/containers.

    Returns:
        dict: Status of container restart operation
    """
    results = await restart_all_containers(SERVERS)
    success = all(result["success"] for result in results)
    return {
        "status": "success" if success else "partial_failure",
        "message": "Containers restarted successfully"
        if success
        else "Some containers failed to restart",
    }


# Main entry point to run the application
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8888, workers=workers)
