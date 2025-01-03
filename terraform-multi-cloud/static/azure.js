import { showDownloadButtons } from './index.js';

export function handleAzure() {
    const azureLoginForm = document.getElementById('azureLoginForm');
    const azureClusterOptions = document.getElementById('azureClusterOptions');
    const azureTerraformApply = document.getElementById('azureTerraformApply');
    const azureTerraformDestroy = document.getElementById('azureTerraformDestroy');
    const statusMessage = document.getElementById('statusMessage');

    azureLoginForm.classList.remove('hidden');
    azureClusterOptions.classList.add('hidden');
    azureTerraformApply.classList.add('hidden');
    azureTerraformDestroy.classList.add('hidden');

    document.getElementById('azureLoginButton').addEventListener('click', function() {
        const azure_username = document.getElementById('azureUsername').value;
        const azure_password = document.getElementById('azurePassword').value;

        statusMessage.style.display = 'block';
        statusMessage.style.color = 'blue';
        statusMessage.innerHTML = 'Processing Azure login, please wait...';

        fetch('/azure-login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                azure_username,
                azure_password,
            }),
        })
        .then((response) => response.json())
        .then((data) => {
            if (data.success) {
                populateAzureOptions(data);
                statusMessage.style.display = 'none';
                azureLoginForm.classList.add('hidden');
                azureClusterOptions.classList.remove('hidden');
                azureTerraformApply.classList.remove('hidden');
                azureTerraformDestroy.classList.remove('hidden');
            } else {
                statusMessage.style.color = 'red';
                statusMessage.innerHTML = 'Azure login failed: ' + (data.message || 'Unknown error');
            }
        })
        .catch((error) => {
            console.error('Error:', error);
            statusMessage.style.color = 'red';
            statusMessage.innerHTML = 'An error occurred during Azure login: ' + error.message;
        });
    });
}

function populateAzureOptions(data) {
    const subscriptionSelect = document.getElementById('azure_subscription_id');
    const resourceGroupSelect = document.getElementById('azure_resource_group');

    subscriptionSelect.innerHTML = data.subscriptionIds.map(
        (id) => `<option value="${id}">${id}</option>`
    ).join('');

    subscriptionSelect.addEventListener('change', function () {
        const selectedSubscription = this.value;
        const resourceGroups = data.resourceGroups[selectedSubscription] || [];
        resourceGroupSelect.innerHTML = resourceGroups.map(
            (group) => `<option value="${group}">${group}</option>`
        ).join('') || '<option>No Resource Groups available</option>';
    });

    subscriptionSelect.dispatchEvent(new Event('change'));
}

document.getElementById('azureTerraformApply').addEventListener('click', () => handleTerraformAction('apply'));
document.getElementById('azureTerraformDestroy').addEventListener('click', () => handleTerraformAction('destroy'));

function handleTerraformAction(action) {
    const subscription_id = document.getElementById('azure_subscription_id').value;
    const resource_group_name = document.getElementById('azure_resource_group').value;
    const selenium_vm_count = document.getElementById('azure_vm_count').value;
    const iij_name_prefix = document.getElementById('azure_iij_name_prefix').value;
    const ssh_admin_username = document.getElementById('azure_ssh_admin_username').value;
    const selenium_address_space = document.getElementById('azure_address_space').value;
    const selenium_subnet_address_prefixes = document.getElementById('azure_subnet_prefixes').value;

    const rawAllowIpInput = document.getElementById('azure_allow_ip_private').value;
    const listAllowIpPrivate = rawAllowIpInput
        .split('\n')
        .map((ip) => ip.trim())
        .filter((ip) => ip);

    const azurepayload = {
        prefix: "azure",
        subscription_id,
        resource_group_name,
        iij_name_prefix,
        selenium_vm_count,
        ssh_admin_username,
        selenium_address_space,
        selenium_subnet_address_prefixes,
        list_allow_ip_private: listAllowIpPrivate,
    };

    const apiEndpoint = `/azure-${action}`;
    const actionMessage = action === 'apply' ? 'Applying Terraform configuration on Azure' : 'Destroying Terraform configuration on Azure';

    const statusMessage = document.getElementById('statusMessage');
    statusMessage.style.display = 'block';
    statusMessage.style.color = 'blue';
    statusMessage.innerHTML = `${actionMessage}, please wait...`;

    fetch(apiEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(azurepayload),
    })
    .then((response) => response.json())
    .then((data) => {
        if (data.success) {
            statusMessage.style.color = 'green';
            statusMessage.innerHTML = `Terraform ${action.charAt(0).toUpperCase() + action.slice(1)} on Azure executed successfully!`;
            showDownloadButtons('azure');
        } else {
            statusMessage.style.color = 'red';
            statusMessage.innerHTML = `Failed to ${action} Terraform on Azure: ${data.message || 'Unknown error'}`;
        }
    })
    .catch((error) => {
        console.error('Error:', error);
        statusMessage.style.color = 'red';
        statusMessage.innerHTML = `An error occurred while trying to ${action} Terraform on Azure: ${error.message}`;
    });
}
