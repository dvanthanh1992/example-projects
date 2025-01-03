import os
import uvicorn
import multiprocessing
from fastapi import FastAPI
from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.middleware.cors import CORSMiddleware
from routes.vcd_routes import router as vcd_router
from routes.azure_routes import router as azure_router
from routes.vcenter_routes import router as vcenter_router
from routes.terraform_routes import router as terraform_router

# Create the main FastAPI application
app = FastAPI()

# Mount template and static files
TEMPLATES = Jinja2Templates(directory="templates")
app.mount("/static", StaticFiles(directory="static"), name="static")

# Configure CORS to allow access from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers for modular API management
app.include_router(vcd_router)
app.include_router(azure_router)
app.include_router(vcenter_router)
app.include_router(terraform_router)

LOG_DIR = os.path.join(os.getcwd(), "logs")

@app.get("/download-log/{service_name}/{log_type}")
async def download_log(service_name: str, log_type: str):
    """
    Download the log or state file for the specified Terraform service.

    Args:
        service_name (str): The name of the service (e.g., vcenter, vcd).
        log_type (str): The type of file to download (e.g., log, tfstate).

    Returns:
        FileResponse: The requested file if it exists.

    Raises:
        HTTPException: If the file does not exist or the service/log type is invalid.
    """
    valid_log_types = ["log", "tfstate", "tfstate.backup"]
    if log_type not in valid_log_types:
        raise HTTPException(status_code=400, detail="Invalid log type.")

    service_log_dir = os.path.join(LOG_DIR, service_name)
    if not os.path.exists(service_log_dir):
        raise HTTPException(status_code=404, detail="Service log directory not found.")

    if log_type == "log":
        files = [f for f in os.listdir(service_log_dir) if f.endswith(".log")]
    elif log_type == "tfstate":
        files = [f for f in os.listdir(service_log_dir) if f.endswith(".tfstate")]
    elif log_type == "tfstate.backup":
        files = [f for f in os.listdir(service_log_dir) if f.endswith(".tfstate.backup")]

    if not files:
        raise HTTPException(status_code=404, detail="No files found for the specified log type.")

    latest_file = max([os.path.join(service_log_dir, f) for f in files], key=os.path.getctime)
    return FileResponse(latest_file, filename=os.path.basename(latest_file))

@app.get("/")
async def read_root():
    """
    Render the application's index page.

    This is the root endpoint of the application. It renders the `index.html`
    template from the `templates` directory.

    Returns:
        TemplateResponse: The rendered index.html template.
    """
    return TEMPLATES.TemplateResponse("index.html", {"request": {}})


if __name__ == "__main__":
    """
    Main entry point to run the application.

    This block calculates the optimal number of worker processes based on the
    number of CPU cores using the Gunicorn-style formula: (2 * cores) + 1.
    It then starts the FastAPI application with Uvicorn.
    """
    cores = multiprocessing.cpu_count()
    workers = (2 * cores) + 1
    uvicorn.run("main:app", host="0.0.0.0", port=7777, workers=workers)
