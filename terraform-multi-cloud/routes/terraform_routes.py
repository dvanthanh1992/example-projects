from pydantic import BaseModel
from fastapi import APIRouter, HTTPException
from routes.terraform_service import handle_terraform_action

router = APIRouter()


class VCenterPayload(BaseModel):
    """
    Payload model for VCenter operations.

    Attributes:
        prefix: Prefix for the VCenter configuration (default: "vcenter").
        vm_cpu_cores: Number of CPU cores for the virtual machine.
        vm_mem_size: Memory size (in MB) for the virtual machine.
        url: URL of the VCenter server.
        username: Username for authentication with the VCenter server.
        password: Password for authentication with the VCenter server.
        datacenter: Datacenter in VCenter to deploy the resources.
        cluster: Cluster in VCenter where resources will be deployed.
        datastore: Datastore to be used for the virtual machine.
        resourcePool: Resource pool for the virtual machine.
        folder: Folder where the virtual machine will be created.
        portgroup: Network portgroup for the virtual machine.
        template: Template to use for creating the virtual machine.
        number_vm: Number of virtual machines to be created.
        selenium_node_count: Number of Selenium nodes to be deployed.
        selenium_hub_ip: IP address of the Selenium hub.
        name_prefix: Prefix for naming the virtual machines.
        ip_cidr: CIDR block for the virtual machine's IP address.
        vm_gateway: Gateway for the virtual machine's network.
        vm_dns: DNS server for the virtual machine.
    """

    prefix: str = "vcenter"
    vm_cpu_cores: int
    vm_mem_size: int
    url: str
    username: str
    password: str
    datacenter: str
    cluster: str
    datastore: str
    resourcePool: str
    folder: str
    portgroup: str
    template: str
    number_vms: int
    selenium_node_count: int
    selenium_hub_ip: str
    name_prefix: str
    ip_cidr: str
    vm_gateway: str
    vm_dns: str


@router.post("/vcenter-apply")
async def vcenter_apply(payload: VCenterPayload):
    """
    Apply Terraform configuration for VCenter.

    Args:
        payload: The payload containing VCenter configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "apply", payload.dict(), service_name="vcenter"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/vcenter-destroy")
async def vcenter_destroy(payload: VCenterPayload):
    """
    Destroy Terraform resources for VCenter.

    Args:
        payload: The payload containing VCenter configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "destroy", payload.dict(), service_name="vcenter"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


class VCDPayload(BaseModel):
    """
    Payload model for VCD operations.

    Attributes:
        prefix: Prefix for the VCD configuration (default: "vcd").
        vm_cpu_cores: Number of CPU cores for the virtual machines.
        vm_mem_size: Memory size (in MB) for the virtual machines.
        url: URL of the VCD server.
        username: Username for authentication with the VCD server.
        token: API token for authentication.
        org: Organization in VCD to deploy the resources.
        vdc: Virtual Data Center (VDC) where resources will be deployed.
        catalog: Catalog to use for the virtual machine templates.
        template: Template to use for creating the virtual machines.
        network: Network to associate with the virtual machines.
        number_vms: Number of virtual machines to be created.
        selenium_node_count: Number of Selenium nodes to be deployed.
        selenium_hub_ip: IP address of the Selenium hub.
        name_prefix: Prefix for naming the virtual machines.
        ip_cidr: CIDR block for the virtual machine's IP address.
    """

    prefix: str = "vcd"
    vm_cpu_cores: int
    vm_mem_size: int
    url: str
    username: str
    token: str
    org: str
    vdc: str
    catalog: str
    template: str
    network: str
    number_vms: int
    selenium_node_count: int
    selenium_hub_ip: str
    name_prefix: str
    ip_cidr: str


@router.post("/vcd-apply")
async def vcd_apply(payload: VCDPayload):
    """
    Apply Terraform configuration for VCD.

    Args:
        payload: The payload containing VCD configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "apply", payload.dict(), service_name="vcd"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/vcd-destroy")
async def vcd_destroy(payload: VCDPayload):
    """
    Destroy Terraform resources for VCD.

    Args:
        payload: The payload containing VCD configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "destroy", payload.dict(), service_name="vcd"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


class AzurePayload(BaseModel):
    """
    Payload model for Azure Terraform operations.

    Attributes:
        subscription_id: Azure Subscription ID.
        iij_name_prefix: Prefix for naming resources.
        resource_group_name: Name of the resource group.
        ssh_admin_username: SSH admin username for VMs.
        list_allow_ip_private: List of allowed private IPs.
        selenium_address_space: Address space for Selenium network.
        selenium_subnet_address_prefixes: Subnet prefixes for Selenium.
        selenium_vm_count: Number of Selenium VMs.
    """

    prefix: str = "azure"
    subscription_id: str
    resource_group_name: str
    selenium_vm_count: int
    iij_name_prefix: str
    ssh_admin_username: str
    selenium_address_space: str
    selenium_subnet_address_prefixes: str
    list_allow_ip_private: list[str]

@router.post("/azure-apply")
async def azure_apply(payload: AzurePayload):
    """
    Apply Terraform configuration for Azure.

    Args:
        payload: The payload containing Azure configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "apply", payload.dict(), service_name="azure"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


@router.post("/azure-destroy")
async def azure_destroy(payload: AzurePayload):
    """
    Destroy Terraform resources for Azure.

    Args:
        payload: The payload containing Azure configuration parameters.

    Returns:
        dict: A response indicating the success or failure of the operation.

    Raises:
        HTTPException: If the operation fails or an exception occurs.
    """
    try:
        result = await handle_terraform_action(
            "destroy", payload.dict(), service_name="azure"
        )
        if not result["success"]:
            raise HTTPException(
                status_code=500, detail=result.get("error", "Unknown error")
            )
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e
