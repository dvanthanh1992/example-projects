from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from .vcenter_task import VMwareTask
import traceback

router = APIRouter()

class VcenterLoginRequest(BaseModel):
    """
    Request model for vCenter login API.

    Attributes:
        vcenter_host (str): The hostname or IP address of the vCenter Server.
        vcenter_user (str): The username for authentication.
        vcenter_pass (str): The password for authentication.
    """
    vcenter_host: str
    vcenter_user: str
    vcenter_pass: str

@router.post("/vcenter-login")
async def login(request: VcenterLoginRequest):
    """
    Login to vCenter Server and retrieve inventory data.

    This endpoint authenticates with vCenter Server using the provided credentials
    and retrieves information about datacenters, clusters, datastores, folders,
    resource pools, portgroups, and templates.

    Args:
        request (VcenterLoginRequest): The login request containing the vCenter
                                       host, username, and password.

    Returns:
        dict: A dictionary containing the following keys:
            - success (bool): Authentication status.
            - datacenters (list[str]): List of datacenters.
            - clusters (list[str]): List of clusters.
            - datastores (list[str]): List of datastores.
            - folders (list[str]): List of folders.
            - resourcePools (list[str]): List of resource pools.
            - portgroups (list[str]): List of network portgroups.
            - templates (list[str]): List of VM templates.

    Raises:
        HTTPException: If an error occurs during login or data retrieval.
    """
    try:
        service_instance = VMwareTask.login_vcenter(
            vcenter_host=request.vcenter_host,
            vcenter_user=request.vcenter_user,
            vcenter_pass=request.vcenter_pass
        )

        datacenters = VMwareTask.get_datacenters(service_instance) or []
        clusters = VMwareTask.get_clusters(service_instance) or []
        datastores = VMwareTask.get_datastores(service_instance) or []
        folders = VMwareTask.get_folders(service_instance) or []
        resource_pools = VMwareTask.get_resource_pools(service_instance) or []
        portgroups = VMwareTask.get_network_portgroups(service_instance) or []
        templates = VMwareTask.get_templates(service_instance) or []

        VMwareTask.logout_vcenter(service_instance)

        return {
            "success": True,
            "datacenters": datacenters,
            "clusters": clusters,
            "datastores": datastores,
            "folders": folders,
            "resourcePools": resource_pools,
            "portgroups": portgroups,
            "templates": templates,
        }
    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e)) from e
