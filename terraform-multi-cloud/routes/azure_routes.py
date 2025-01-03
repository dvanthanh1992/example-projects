from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from .azure_task import AzureTask
import traceback

router = APIRouter()

class AzureLoginRequest(BaseModel):
    """
    Request model for Azure login API.

    Attributes:
        username (str): The username for authentication.
        password (str): The password for authentication.
    """

    azure_username: str
    azure_password: str

@router.post("/azure-login")
async def login(request: AzureLoginRequest):
    """
    Login to Azure and retrieve subscription and resource group data.

    This endpoint authenticates with Azure using the provided credentials
    and retrieves the subscription IDs and a list of resource groups.

    Args:
        request (AzureLoginRequest): The login request containing the Azure
                                      username and password.

    Returns:
        dict: A dictionary containing the following keys:
            - success (bool): Authentication status.
            - subscriptionIds (list[str]): The subscription IDs.
            - resourceGroups (list[dict]): List of resource groups with names and locations.

    Raises:
        HTTPException: If an error occurs during login or data retrieval.
    """
    try:
        AzureTask.login_azure(request.azure_username, request.azure_password)
        subscription_ids = AzureTask.get_all_subscription_ids()
        resource_groups_by_subscription = {
            sub_id: AzureTask.get_resource_groups(sub_id) for sub_id in subscription_ids
        }

        return {
            "success": True,
            "subscriptionIds": subscription_ids,
            "resourceGroups": resource_groups_by_subscription,
        }
    except Exception as e:
        print(f"Error: {e}")
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e)) from e

