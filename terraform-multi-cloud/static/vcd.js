import { showDownloadButtons } from './index.js';

export function handleVCD() {
    const vcdLoginForm = document.getElementById('vcdLoginForm');
    const vcdClusterOptions = document.getElementById('vcdClusterOptions');
    const vcdTerraformApply = document.getElementById('vcdTerraformApply');
    const vcdTerraformDestroy = document.getElementById('vcdTerraformDestroy');
	const statusMessage = document.getElementById('statusMessage');
	
    vcdLoginForm.classList.remove('hidden');
    vcdClusterOptions.classList.add('hidden');
    vcdTerraformApply.classList.add('hidden');
    vcdTerraformDestroy.classList.add('hidden');

	document.getElementById('vcdLoginButton').addEventListener('click', function() {
		const url = document.getElementById('vcdUrl').value;
		const username = document.getElementById('vcdUsername').value;
		const token = document.getElementById('vcdToken').value;

        statusMessage.style.display = 'block';
        statusMessage.style.color = 'blue';
        statusMessage.innerHTML = 'Processing, please wait...';

		fetch('/vcd-login', {
				method: 'POST',
				headers: {
					'Content-Type': 'application/json'
				},
				body: JSON.stringify({
					vcd_url: url,
					vcd_user: username,
					vcd_token: token
				}),
			})
			.then((response) => response.json())
			.then((data) => {
				if (data.success) {
					populateVCDOptions(data);
					statusMessage.style.display = 'none';
					vcdLoginForm.classList.add('hidden');
					vcdClusterOptions.classList.remove('hidden');
					vcdTerraformApply.classList.remove('hidden');
					vcdTerraformDestroy.classList.remove('hidden');

				} else {
					statusMessage.style.color = 'red';
					statusMessage.innerHTML = 'VCD Login Failed: ' + (data.detail || 'The Username or API Token is Incorrect');
				}
			})
			.catch((error) => {
				console.error('Error:', error);
				statusMessage.style.color = 'red';
				statusMessage.innerHTML = 'An error occurred: ' + error.message;
			});
	});
}

function populateVCDOptions(data) {
	const orgSelect = document.getElementById('vcd_org');
	const vdcSelect = document.getElementById('vcd_vdc');
	const catalogSelect = document.getElementById('vcd_catalog');
	const templateSelect = document.getElementById('vcd_template');
	const networkSelect = document.getElementById('vcd_network');

	orgSelect.innerHTML = data.orgs?.map(org => `<option value="${org}">${org}</option>`).join('') || '<option>No Organizations available</option>';
	vdcSelect.innerHTML = data.vdcs?.map(vdc => `<option value="${vdc}">${vdc}</option>`).join('') || '<option>No VDCs available</option>';
	catalogSelect.innerHTML = data.catalogs?.map(catalog => `<option value="${catalog}">${catalog}</option>`).join('') || '<option>No Catalogs available</option>';
	templateSelect.innerHTML = data.templates?.map(template => `<option value="${template}">${template}</option>`).join('') || '<option>No Templates available</option>';
	networkSelect.innerHTML = data.networks?.map(network => `<option value="${network}">${network}</option>`).join('') || '<option>No Networks available</option>';
}

document.getElementById('vcdTerraformApply').addEventListener('click', () => handleTerraformAction('apply'));
document.getElementById('vcdTerraformDestroy').addEventListener('click', () => handleTerraformAction('destroy'));

function handleTerraformAction(action) {
    const resourceSizeInput = document.getElementById('vcd_resource_size').value;
    let vm_cpu_cores = 0;
    let vm_mem_size = 0;
    if (resourceSizeInput === "vcd_small") {
        vm_cpu_cores = 2;
        vm_mem_size = 4096;
    } else if (resourceSizeInput === "vcd_medium") {
        vm_cpu_cores = 4;
        vm_mem_size = 8192;
    } else if (resourceSizeInput === "vcd_large") {
        vm_cpu_cores = 8;
        vm_mem_size = 16384;
    }

    const url = document.getElementById('vcdUrl').value;
    const username = document.getElementById('vcdUsername').value;
    const token = document.getElementById('vcdToken').value;
    const org = document.getElementById('vcd_org').value;
    const vdc = document.getElementById('vcd_vdc').value;
    const catalog = document.getElementById('vcd_catalog').value;
    const template = document.getElementById('vcd_template').value;
    const network = document.getElementById('vcd_network').value;
    const number_vms = document.getElementById('vcd_number_vms').value;
    const selenium_node_count = document.getElementById('vcd_selenium_node_count').value;
    const selenium_hub_ip = document.getElementById('vcd_selenium_hub_ip').value;
    const name_prefix = document.getElementById('vcd_name_prefix').value;
    const ip_cidr = document.getElementById('vcd_ip_cidr').value;

    const vcdpayload = {
        prefix: "vcd",
        vm_cpu_cores,
        vm_mem_size,
        url,
        username,
        token,
        org,
        vdc,
        catalog,
        template,
        network,
        number_vms,
        selenium_node_count,
        selenium_hub_ip,
        name_prefix,
        ip_cidr
    };

    const apiEndpoint = `/vcd-${action}`;
    const actionMessage = action === 'apply' ? 'Applying Terraform configuration on VMware Cloud Director' : 'Destroying Terraform configuration on VMware Cloud Director';

    const statusMessage = document.getElementById('statusMessage');
    statusMessage.style.display = 'block';
    statusMessage.style.color = 'blue';
    statusMessage.innerHTML = `${actionMessage}, please wait...`;

    fetch(apiEndpoint, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(vcdpayload)
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            statusMessage.style.color = 'green';
            statusMessage.innerHTML = `Terraform ${action.charAt(0).toUpperCase() + action.slice(1)} on VMware Cloud Director executed successfully!`;
            showDownloadButtons('vcd');
        } else {
            statusMessage.style.color = 'red';
            statusMessage.innerHTML = `Failed to ${action} Terraform on VMware Cloud Director: ${data.message || 'Unknown error'}`;
        }
    })
    .catch(error => {
        console.error('Error:', error);
        statusMessage.style.color = 'red';
        statusMessage.innerHTML = `An error occurred while trying to ${action} Terraform on VMware Cloud Director: ${error.message}`;
    });
}
