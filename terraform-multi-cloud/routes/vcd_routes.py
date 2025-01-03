import traceback
from .vcd_task import VCDTask
from pydantic import BaseModel
from fastapi import APIRouter, HTTPException

router = APIRouter()

class VCDLoginRequest(BaseModel):
    """
    Request model for VCD login API.

    Attributes:
        vcd_url (str): The URL of the VMware Cloud Director.
        vcd_user (str): The username for VMware Cloud Director authentication.
        vcd_token (str): The API token for VMware Cloud Director authentication.
    """
    vcd_url: str
    vcd_user: str
    vcd_token: str

@router.post("/vcd-login")
async def vcd_login(request: VCDLoginRequest):
    """
    Authenticate with VMware Cloud Director and retrieve organizational data.

    Args:
        request (VCDLoginRequest): The login request containing VCD URL, username, and API token.

    Returns:
        dict: A dictionary containing the authentication status and retrieved data:
            - success (bool): Authentication success status.
            - orgs (list[str]): List of organization names.
            - vdcs (list[str]): List of virtual data center names.
            - catalogs (list[str]): List of catalog names.
            - templates (list[str]): List of vApp template names.
            - networks (list[str]): List of network names.

    Raises:
        HTTPException: If authentication fails or an error occurs during processing.
    """
    try:
        token = VCDTask.authenticate_vcd_account(
            url_provider=request.vcd_url,
            client_username=request.vcd_user,
            client_api_token=request.vcd_token
        )

        if not token:
            raise HTTPException(status_code=401, detail="Authentication failed. Please check your credentials.")
        
        orgs = VCDTask.list_organizations(url_provider=request.vcd_url, token=token)
        vdcs = VCDTask.list_vdcs(url_provider=request.vcd_url, token=token)
        catalogs = VCDTask.list_catalogs(url_provider=request.vcd_url, token=token)
        templates = VCDTask.list_templates(url_provider=request.vcd_url, token=token)
        networks = VCDTask.list_networks(url_provider=request.vcd_url, token=token)

        return {
            "success": True,
            "orgs": [org["name"] for org in orgs],
            "vdcs": [vdc["name"] for vdc in vdcs],
            "catalogs": [catalog["catalogName"] for catalog in catalogs],
            "templates": [template["vAppName"] for template in templates],
            "networks": [network["name"] for network in networks],
        }

    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e)) from e
