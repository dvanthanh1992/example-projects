import { showDownloadButtons } from './index.js';

export function handleVCenter() {
    const loginForm = document.getElementById('vcenterLoginForm');
    const clusterOptions = document.getElementById('vcenterClusterOptions');
    const vcenterTerraformApply = document.getElementById('vcenterTerraformApply');
    const vcenterTerraformDestroy = document.getElementById('vcenterTerraformDestroy');
	const statusMessage = document.getElementById('statusMessage');

    loginForm.classList.remove('hidden');
    clusterOptions.classList.add('hidden');
    vcenterTerraformApply.classList.add('hidden');
    vcenterTerraformDestroy.classList.add('hidden');

	document.getElementById('vcenterLoginButton').addEventListener('click', function() {
		const url = document.getElementById('vcenterUrl').value;
		const username = document.getElementById('vcenterUsername').value;
		const password = document.getElementById('vcenterPassword').value;

        statusMessage.style.display = 'block';
        statusMessage.style.color = 'blue';
        statusMessage.innerHTML = 'Processing, please wait...';

		fetch('/vcenter-login', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					vcenter_host: url,
					vcenter_user: username,
					vcenter_pass: password
				}),
			})
			.then((response) => response.json())
			.then((data) => {
				if (data.success) {
					populateVCenterOptions(data);
					statusMessage.style.display = 'none';
					loginForm.classList.add('hidden');
					clusterOptions.classList.remove('hidden');
					vcenterTerraformApply.classList.remove('hidden');
					vcenterTerraformDestroy.classList.remove('hidden');

				} else {
					statusMessage.style.color = 'red';
					statusMessage.innerHTML = 'vCenter Login failed: ' + (data.message || 'The Username or Password is Incorrect');
				}
			})
			.catch((error) => {
				console.error('Error:', error);
				statusMessage.style.color = 'red';
				statusMessage.innerHTML = 'An error occurred: ' + error.message;
			});
	});
}

function populateVCenterOptions(data) {
    const datacenterSelect = document.getElementById('vcenter_datacenter');
	const clusterSelect = document.getElementById('vcenter_cluster');
	const datastoreSelect = document.getElementById('vcenter_datastore');
	const resourcePoolSelect = document.getElementById('vcenter_resourcePool');
	const folderSelect = document.getElementById('vcenter_folder');
	const portgroupSelect = document.getElementById('vcenter_portgroup');
    const templateSelect = document.getElementById('vcenter_template');

    datacenterSelect.innerHTML = data.datacenters?.map(c => `<option value="${c}">${c}</option>`).join('') || '<option>No clusters available</option>';
	clusterSelect.innerHTML = data.clusters?.map(c => `<option value="${c}">${c}</option>`).join('') || '<option>No clusters available</option>';
	datastoreSelect.innerHTML = data.datastores?.map(d => `<option value="${d}">${d}</option>`).join('') || '<option>No datastores available</option>';
	folderSelect.innerHTML = data.folders?.map(f => `<option value="${f}">${f}</option>`).join('') || '<option>No folders available</option>';
	resourcePoolSelect.innerHTML = data.resourcePools?.map(r => `<option value="${r}">${r}</option>`).join('') || '<option>No resource pools available</option>';
	portgroupSelect.innerHTML = data.portgroups?.map(p => `<option value="${p}">${p}</option>`).join('') || '<option>No portgroups available</option>';
    templateSelect.innerHTML = data.templates?.map(p => `<option value="${p}">${p}</option>`).join('') || '<option>No portgroups available</option>';
}

document.getElementById('vcenterTerraformApply').addEventListener('click', () => handleTerraformAction('apply'));
document.getElementById('vcenterTerraformDestroy').addEventListener('click', () => handleTerraformAction('destroy'));

function handleTerraformAction(action) {
    const resourceSizeInput = document.getElementById('vcenter_resource_size').value;
    let vm_cpu_cores = 0;
    let vm_mem_size = 0;
    if (resourceSizeInput === "vcenter_small") {
        vm_cpu_cores = 2;
        vm_mem_size = 4096;
    } else if (resourceSizeInput === "vcenter_medium") {
        vm_cpu_cores = 4;
        vm_mem_size = 8192;
    } else if (resourceSizeInput === "vcenter_large") {
        vm_cpu_cores = 8;
        vm_mem_size = 16384;
    }

    const url = document.getElementById('vcenterUrl').value;
    const username = document.getElementById('vcenterUsername').value;
    const password = document.getElementById('vcenterPassword').value;
    const datacenter = document.getElementById('vcenter_datacenter').value;
    const cluster = document.getElementById('vcenter_cluster').value;
    const datastore = document.getElementById('vcenter_datastore').value;
    const resourcePool = document.getElementById('vcenter_resourcePool').value;
    const folder = document.getElementById('vcenter_folder').value;
    const portgroup = document.getElementById('vcenter_portgroup').value;
    const template = document.getElementById('vcenter_template').value;
    const number_vms = document.getElementById('vcenter_number_vms').value;
    const selenium_node_count = document.getElementById('vcenter_selenium_node_count').value;
    const selenium_hub_ip = document.getElementById('vcenter_selenium_hub_ip').value;
    const name_prefix = document.getElementById('vcenter_name_prefix').value;
    const ip_cidr = document.getElementById('vcenter_ip_cidr').value;
    const vm_gateway = document.getElementById('vcenter_vm_gateway').value;
    const vm_dns = document.getElementById('vcenter_vm_dns').value;

    const vcenterpayload = {
        prefix: "vcenter",
        vm_cpu_cores,
        vm_mem_size,
        url,
        username,
        password,
        datacenter,
        cluster,
        datastore,
        resourcePool,
        folder,
        portgroup,
        template,
        number_vms,
        selenium_node_count,
        selenium_hub_ip,
        name_prefix,
        ip_cidr,
        vm_gateway,
        vm_dns,
    };

    const apiEndpoint = `/vcenter-${action}`;
    const actionMessage = action === 'apply' ? 'Applying Terraform configuration on vCenter Server' : 'Destroying Terraform configuration on vCenter Server';

    const statusMessage = document.getElementById('statusMessage');
    statusMessage.style.display = 'block';
    statusMessage.style.color = 'blue';
    statusMessage.innerHTML = `${actionMessage}, please wait...`;

    fetch(apiEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(vcenterpayload)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            statusMessage.style.color = 'green';
            statusMessage.innerHTML = `Terraform ${action.charAt(0).toUpperCase() + action.slice(1)} on vCenter Server executed successfully!`;
            showDownloadButtons('vcenter');
        } else {
            statusMessage.style.color = 'red';
            statusMessage.innerHTML = `Failed to ${action} Terraform on vCenter Server: ${data.message || 'Unknown error'}`;
        }
    })
    .catch(error => {
        console.error('Error:', error);
        statusMessage.style.color = 'red';
        statusMessage.innerHTML = `An error occurred while trying to ${action} Terraform on vCenter Server: ${error.message}`;
    });
}
