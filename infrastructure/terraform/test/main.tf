terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.54.1"
    }
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.108.0"
    }
    google = {
      source = "hashicorp/google"
      version = "5.34.0"
    }
    # KVM
    libvirt = { 
      source = "dmacvicar/libvirt"
      version = "0.7.6"
    }
    vsphere = {
      source = "hashicorp/vsphere"
      version = "2.8.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.31.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = "4.3.0"
    }
  }
  required_version = ">= 1.8.0"
}

locals {

  target_provider         = var.target_provider

  k8s_cluster_configs = {
    master = {
      vm_name             = "${var.vm_name_prefix}-master"
      vm_cpu_cores        = var.k8s_master_cpu
      vm_mem_size         = var.k8s_master_ram
      vm_ip_address       = var.k8s_master_ip
    }
    worker = {
      vm_name             = "${var.vm_name_prefix}-worker"
      vm_cpu_cores        = var.k8s_worker_cpu
      vm_mem_size         = var.k8s_worker_ram
      vm_ip_address       = var.k8s_worker_ip
    }
  }

  ha_proxy_configs = {
    master = {
      vm_name             = "${var.vm_name_prefix}-ha-proxy"
      vm_cpu_cores        = var.k8s_ha_proxy_cpu
      vm_mem_size         = var.k8s_ha_proxy_ram
      vm_ip_address       = var.k8s_ha_proxy_ip
    }
  }
}

module "create_k8s_cluster" {
  source                  = "./modules/k8s-cluster"
  target_provider         = var.target_provider
}
