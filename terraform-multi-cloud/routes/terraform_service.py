import os
import re
import shutil
import asyncio
from typing import Optional, Tuple, Dict
from datetime import datetime

# Directory for logs
LOG_DIR = os.path.join(os.getcwd(), "logs")

# Ensure the log directory exists
os.makedirs(LOG_DIR, exist_ok=True)

def map_payload_to_terraform_vars(payload: dict, prefix: str) -> Tuple[Dict[str, str], Dict[str, str]]:
    """
    Maps the given payload to Terraform variable files and sensitive variables.

    Args:
        payload (dict): The payload containing input data.
        prefix (str): The prefix to determine the type of mapping (e.g., "vcenter" or "vcd").

    Returns:
        Tuple[Dict[str, str], Dict[str, str]]: A tuple containing file variables and sensitive variables.
    """
    if prefix == "vcenter":
        sensitive_vars = {
            "vsphere_password": payload.get("password"),
        }
        file_vars = {
            "vm_cpu_cores": payload.get("vm_cpu_cores"),
            "vm_mem_size": payload.get("vm_mem_size"),
            "vsphere_endpoint": payload.get("url"),
            "vsphere_username": payload.get("username"),
            "vsphere_datacenter": payload.get("datacenter"),
            "vsphere_cluster": payload.get("cluster"),
            "vsphere_datastore": payload.get("datastore"),
            "vsphere_resource_pool": payload.get("resourcePool"),
            "vsphere_folder": payload.get("folder"),
            "vsphere_network": payload.get("portgroup"),
            "vsphere_vm_template_name": payload.get("template"),
            "number_vms": payload.get("number_vms", "1"),
            "vm_name_prefix": payload.get("name_prefix"),
            "base_vm_ip_cidr": payload.get("ip_cidr"),
            "selenium_node_count": payload.get("selenium_node_count"),
            "selenium_hub_ip": payload.get("selenium_hub_ip"),
            "vm_gateway": payload.get("vm_gateway"),
            "vm_dns": payload.get("vm_dns"),
        }
    elif prefix == "vcd":
        sensitive_vars = {
            "vcd_api_token": payload.get("token"),
        }
        file_vars = {
            "vm_cpu_cores": payload.get("vm_cpu_cores"),
            "vm_mem_size": payload.get("vm_mem_size"),
            "vcd_url_api": payload.get("url"),
            "vcd_org_name": payload.get("org"),
            "vcd_vdc_name": payload.get("vdc"),
            "vcd_catalog_name": payload.get("catalog"),
            "vcd_vapp_template_name": payload.get("template"),
            "vcd_vm_network_card": payload.get("network"),
            "number_vms": payload.get("number_vms", "1"),
            "vm_name_prefix": payload.get("name_prefix"),
            "base_vm_ip_cidr": payload.get("ip_cidr"),
            "selenium_node_count": payload.get("selenium_node_count"),
            "selenium_hub_ip": payload.get("selenium_hub_ip"),
            "vm_gateway": payload.get("vm_gateway"),
            "vm_dns": payload.get("vm_dns"),
        }
    elif prefix == "azure":
        sensitive_vars = {}
        file_vars = {
            "subscription_id": payload.get("subscription_id"),
            "resource_group_name": payload.get("resource_group_name"),
            "selenium_vm_count": payload.get("selenium_vm_count"),
            "iij_name_prefix": payload.get("iij_name_prefix"),
            "ssh_admin_username": payload.get("ssh_admin_username"),
            "selenium_address_space": f'[{payload.get("selenium_address_space")}]',
            "selenium_subnet_address_prefixes": f'[{payload.get("selenium_subnet_address_prefixes")}]',
            "list_allow_ip_private": f'{payload.get("list_allow_ip_private")}',
        }
    else:
        raise ValueError("Unknown prefix in payload")
    return file_vars, sensitive_vars

def write_tfvars_file(file_vars: dict, terraform_dir: str) -> None:
    """
    Writes Terraform variable files to the specified directory.

    Args:
        file_vars (dict): The non-sensitive variables for Terraform.
        terraform_dir (str): The directory where the .tfvars file will be written.

    Raises:
        Exception: If the file writing process fails.
    """
    tfvars_path = os.path.join(terraform_dir, "terraform.auto.tfvars")
    try:
        os.makedirs(terraform_dir, exist_ok=True)
        with open(tfvars_path, "w", encoding="utf-8") as tfvars_file:
            for key, value in file_vars.items():
                if value is not None:
                    tfvars_file.write(f'{key} = "{value}"\n')
    except Exception as e:
        print(f"Error writing tfvars file: {e}")
        raise e

def remove_ansi_escape_sequences(log_content: str) -> str:
    """
    Removes ANSI escape sequences from the given log content.

    Args:
        log_content (str): The log content with potential ANSI sequences.

    Returns:
        str: The cleaned log content without ANSI sequences.
    """
    ansi_escape = re.compile(r"\x1B(?:[@-Z\\-_]|\[[0-?]*[ -/]*[@-~])")
    return ansi_escape.sub("", log_content)

def save_logs_and_state(action: str, process_stdout: str, terraform_dir: str, service_name: str = "") -> None:
    """
    Saves logs and Terraform state files for a given action.

    Args:
        action (str): The Terraform action (e.g., "apply" or "destroy").
        process_stdout (str): The standard output from the Terraform process.
        terraform_dir (str): The directory containing the Terraform configuration.
        service_name (str, optional): The service name for the logs. Defaults to "".

    Raises:
        Exception: If any file operations fail.
    """
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    log_filename = f"{service_name}_{action}_stdout_{timestamp}.log"
    service_log_dir = os.path.join(LOG_DIR, service_name)
    os.makedirs(service_log_dir, exist_ok=True)
    log_filepath = os.path.join(service_log_dir, log_filename)

    try:
        clean_stdout = remove_ansi_escape_sequences(process_stdout)
        with open(log_filepath, "w", encoding="utf-8") as log_file:
            log_file.write(clean_stdout)

        tfstate_file = os.path.join(terraform_dir, "terraform.tfstate")
        tfstate_backup_file = os.path.join(terraform_dir, "terraform.tfstate.backup")

        if os.path.exists(tfstate_file):
            shutil.copy(
                tfstate_file, os.path.join(service_log_dir, f"terraform_{timestamp}.tfstate")
            )
        if os.path.exists(tfstate_backup_file):
            shutil.copy(
                tfstate_backup_file,
                os.path.join(service_log_dir, f"terraform_{timestamp}.tfstate.backup"),
            )
    except Exception as e:
        print(f"Error saving logs and state files: {e}")
        raise e

async def run_terraform_command(action: str, terraform_dir: str, file_vars: Optional[dict] = None, sensitive_vars: Optional[dict] = None) -> dict:
    """
    Runs a Terraform command asynchronously.

    Args:
        action (str): The Terraform action (e.g., "apply" or "destroy").
        terraform_dir (str): The directory containing the Terraform configuration.
        file_vars (Optional[dict], optional): Non-sensitive variables for Terraform. Defaults to None.
        sensitive_vars (Optional[dict], optional): Sensitive variables for Terraform. Defaults to None.

    Returns:
        dict: A dictionary containing the success status and any output or error messages.
    """
    try:
        os.chdir(terraform_dir)
        
        # Run 'terraform init'
        init_command = ["terraform", "init"]
        init_process = await asyncio.create_subprocess_exec(
            *init_command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        init_stdout, init_stderr = await init_process.communicate()
        print(f"[Terraform Init stdout]: {init_stdout.decode()}")
        print(f"[Terraform Init stderr]: {init_stderr.decode()}")

        if init_process.returncode != 0:
            return {"success": False, "error": f"Terraform init failed: {init_stderr.decode()}"}

        # Build Terraform action command
        command = ["terraform", action, "-auto-approve"]
        if sensitive_vars:
            for key, value in sensitive_vars.items():
                if value:
                    command.extend(["-var", f"{key}={value}"])

        process = await asyncio.create_subprocess_exec(
            *command,
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()

        # Log Terraform action stdout and stderr
        print(f"[Terraform {action} stdout]: {stdout.decode()}")
        print(f"[Terraform {action} stderr]: {stderr.decode()}")

        if process.returncode != 0:
            return {"success": False, "error": stderr.decode()}

        # Save logs and Terraform state
        save_logs_and_state(action, stdout.decode(), terraform_dir, service_name=terraform_dir.split('/')[-1])
        
        return {"success": True, "message": stdout.decode()}
    except Exception as e:
        print(f"Error occurred: {e}")  # Log exception
        return {"success": False, "error": str(e)}

async def handle_terraform_action(action: str, payload: dict, service_name: str = "") -> dict:
    """
    Handles a Terraform action by preparing the configuration and running the command.

    Args:
        action (str): The Terraform action to perform (e.g., "apply" or "destroy").
        payload (dict): The payload containing input variables.
        service_name (str, optional): The name of the service. Defaults to "".

    Returns:
        dict: A dictionary containing the success status and any output or error messages.
    """
    try:
        service_name = service_name.strip("/")
        terraform_dir = os.path.join(os.getcwd(), "terraform", service_name)
        service_log_dir = os.path.join(LOG_DIR, service_name)
        os.makedirs(service_log_dir, exist_ok=True)
        file_vars, sensitive_vars = map_payload_to_terraform_vars(payload, service_name)

        if action == "apply":
            write_tfvars_file(file_vars, terraform_dir)

        return await run_terraform_command(action, terraform_dir, file_vars if action == "apply" else None, sensitive_vars)
    except Exception as e:
        print(f"Error in handle_terraform_action: {e}")
        return {"success": False, "error": str(e)}
