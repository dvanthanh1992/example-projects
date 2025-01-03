import { handleVCD } from './vcd.js';
import { handleAzure } from './azure.js';
import { handleVCenter } from './vcenter.js';

document.getElementById('platformSelect').addEventListener('change', function () {
  const platform = this.value;

  const vcenterLoginForm = document.getElementById('vcenterLoginForm');
  const vcenterClusterOptions = document.getElementById('vcenterClusterOptions');
  const vcdLoginForm = document.getElementById('vcdLoginForm');
  const vcdClusterOptions = document.getElementById('vcdClusterOptions');
  const vcdTerraformApply = document.getElementById('vcdTerraformApply');
  const vcdTerraformDestroy = document.getElementById('vcdTerraformDestroy');
  const vcenterTerraformApply = document.getElementById('vcenterTerraformApply');
  const vcenterTerraformDestroy = document.getElementById('vcenterTerraformDestroy');
  const awsAzurePlaceholder = document.getElementById('awsAzurePlaceholder');
  const azureLoginForm = document.getElementById('azureLoginForm');
  const azureTerraformApply = document.getElementById('azureTerraformApply');
  const azureTerraformDestroy = document.getElementById('azureTerraformDestroy');
  const statusMessage = document.getElementById('statusMessage');

  // Reset visibility for all sections
  vcenterLoginForm.classList.add('hidden');
  vcenterClusterOptions.classList.add('hidden');
  vcdLoginForm.classList.add('hidden');
  vcdClusterOptions.classList.add('hidden');
  awsAzurePlaceholder.classList.add('hidden');
  vcdTerraformApply.classList.add('hidden');
  vcdTerraformDestroy.classList.add('hidden');
  vcenterTerraformApply.classList.add('hidden');
  vcenterTerraformDestroy.classList.add('hidden');
  azureLoginForm.classList.add('hidden');
  azureTerraformApply.classList.add('hidden');
  azureTerraformDestroy.classList.add('hidden');
  statusMessage.classList.add('hidden');

  // Handle platform selection
  if (platform === 'vsphere') {
    handleVCenter();
  } else if (platform === 'vcd') {
    handleVCD();
  } else if (platform === 'azure') {
    handleAzure();
  } else if (platform === 'aws') {
    awsAzurePlaceholder.classList.remove('hidden');
  }
});

export function showDownloadButtons(service) {
  const downloadContainer = document.getElementById('downloadContainer');
  downloadContainer.innerHTML = '';

  ['log', 'tfstate', 'tfstate.backup'].forEach((type) => {
    const button = document.createElement('a');
    button.href = `/download-log/${service}/${type}`;
    button.textContent = `Download ${type.toUpperCase()}`;
    button.target = '_blank';
    downloadContainer.appendChild(button);
  });

  downloadContainer.style.display = 'block';
}
