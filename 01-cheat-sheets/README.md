# Cheat Sheets

## Table of Contents
- [Docker](#docker)
    - [Running Containers](#running-containers)
    - [Container Bulk Management](#container-bulk-management)
    - [Inspect Containers](#inspect-containers)
    - [Executing Commands](#executing-commands)
    - [Images](#images)
    - [Volumes](#volumes)
- [Kubectl](#kubectl)
    - [Contexts and Configuration](#contexts-and-configuration)
    - [Cluster Management](#cluster-management)
    - [Resource Management](#resource-management)
    - [Pod Management](#pod-management)
    - [Service Management](#service-management)
    - [Deployment Management](#deployment-management)
    - [Namespace Management](#namespace-management)
- [Helm](#helm)
    - [Repository Management](#repository-management-1)
    - [Chart Management](#chart-management)
    - [Install Delete Helm Charts](#install-delete-helm-charts)
    - [Upgrading Helm Charts](#upgrading-helm-charts)
    - [Creating Helm Charts](#creating-helm-charts)
- [Terraform](#terraform)
    - [Format and Validate](#format-and-validate)
    - [Initialize Working Directory](#initialize-working-directory)
    - [Plan, Deploy and Cleanup](#plan-deploy-and-cleanup)
    - [Workspaces](#workspaces)
    - [State Manipulation](#state-manipulation)
    - [Import and Outputs](#import-and-outputs)
    - [Terraform Cloud](#terraform-cloud)
- [Git](#git)
    - [Repository Management](#repository-management)
    - [Configuration](#configuration)
    - [Remote Repositories](#remote-repositories)
- [OpenSSL](#openssl)
    - [Certificate Management](#certificate-management)
    - [Key Management](#key-management)
    - [Certificate Signing](#certificate-signing)
    - [Certificate Conversion](#certificate-conversion)
    - [Encryption and Decryption](#encryption-and-decryption)
    - [Miscellaneous](#miscellaneous)

## Docker

### Running Containers

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker run <image>` | Start a new container from an image |
| `docker run -it <image>` | Start a new container in interactive mode |
| `docker run --rm <image>` | Start a new container and remove it when it exits |
| `docker create <image>` | Create a new container |
| `docker start <container>` | Start a container |
| `docker stop <container>` | Graceful stop a container |
| `docker kill <container>` | Kill (SIGKILL) a container |
| `docker restart <container>` | Graceful stop and restart a container |
| `docker pause <container>` | Suspend a container |
| `docker unpause <container>` | Resume a container |
| `docker rm <container>` | Destroy a container |

### Container Bulk Management

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker stop $(docker ps -q)` | To stop all the running containers |
| `docker stop $(docker ps -a -q)` | To stop all the stopped and running containers |
| `docker kill $(docker ps -q)` | To kill all the running containers |
| `docker kill $(docker ps -a -q)` | To kill all the stopped and running containers |
| `docker restart $(docker ps  -q)` | To restart all  running containers |
| `docker restart $(docker ps -a -q)` | To restart all the stopped and running containers |
| `docker rm $(docker ps  -q)` | To destroy all running containers |
| `docker rm $(docker ps -a -q)` | To destroy all the stopped and running containers |
| `docker pause $(docker ps  -q)` | To pause all  running containers |
| `docker pause $(docker ps -a -q)` | To pause all the stopped and running containers |
| `docker start $(docker ps  -q)` | To start all  running containers |
| `docker start $(docker ps -a -q)` | To start all the stopped and running containers |
| `docker rm -vf $(docker ps -a -q)` | To delete all containers including its volumes use |
| `docker rmi -f $(docker images -a -q)` | To delete all the images |
| `docker system prune` | To delete all dangling and unused images, containers, cache and volumes |
| `docker system prune -a` | To delete all used and unused images |
| `docker system prune --volumes` | To delete all docker volumes |

### Inspect Containers

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker ps` | List running containers |
| `docker ps --all` | List all containers, including stopped |
| `docker logs <container>` | Show a container output |
| `docker logs -f <container>` | Follow a container output |
| `docker top <container>` | List the processes running in a container |
| `docker diff` | Show the differences with the image (modified files) |
| `docker inspect` | Show information of a container (json formatted) |

### Executing Commands

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker attach <container>` | Attach to a container |
| `docker cp <container>:<container-path> <host-path>` | Copy files from the container |
| `docker cp <host-path> <container>:<container-path>` | Copy files into the container |
| `docker export <container>` | Export the content of the container (tar archive) |
| `docker exec <container>` | Run a command inside a container |
| `docker exec -it <container> /bin/bash` | Open an interactive shell inside a container (there is no bash in some images, use /bin/sh) |
| `docker wait <container>` | Wait until the container terminates and return the exit code |

### Images

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker image ls` | List all local images |
| `docker history <image>` | Show the image history |
| `docker inspect <image>` | Show information (json formatted) |
| `docker tag <image> <tag>` | Tag an image |
| `docker commit <container> <image>` | Create an image (from a container) |
| `docker import <url>` | Create an image (from a tarball) |
| `docker rmi <image>` | Delete images |
| `docker pull <user>/<repository>:<tag>` | Pull an image from a registry |
| `docker push <user>/<repository>:<tag>` | Push and image to a registry |
| `docker search <test>` | Search an image on the official registry |
| `docker login` | Login to a registry |
| `docker logout` | Logout from a registry |
| `docker save <user>/<repository>:<tag>` | Export an image/repo as a tarball |
| `docker load` | Load images from a tarball |

### Volumes

| COMMAND | DESCRIPTION |
| --- | --- |
| `docker volume ls` | List all vol1umes |
| `docker volume create <volume>` | Create a volume |
| `docker volume inspect <volume>` | Show information (json formatted) |
| `docker volume rm <volume>` | Destroy a volume |
| `docker volume ls --filter="dangling=true"` | List all dangling volumes (not referenced by any container) |
| `docker volume prune` | Delete all volumes (not referenced by any container) |
| `docker run --rm --volumes-from <container> -v $(pwd):/backup busybox tar cvfz /backup/backup.tar <container-path>` | Backup a container |
| `docker run --rm --volumes-from <container> -v $(pwd):/backup busybox sh -c "cd <container-path> && tar xvf /backup/backup.tar --strip 1"` | Restore a container from backup |

## Kubectl

### Contexts and Configuration

| Command | Description |
| --- | --- |
| `kubectl config view` | Show the current kubeconfig file |
| `kubectl config get-contexts` | List all contexts in the kubeconfig file |
| `kubectl config current-context` | Show the current context |
| `kubectl config use-context <context>` | Change the current context |
| `kubectl config set-context <context> --namespace=<namespace>` | Set the namespace for a context |
| `kubectl config set-context <context> --cluster=<cluster>` | Set the cluster for a context |
| `kubectl config set-context <context> --user=<user>` | Set the user for a context |
| `kubectl config set-context <context> --namespace=<namespace> --cluster=<cluster> --user=<user>` | Set all context properties |

### Cluster Management

| Command | Description |
| --- | --- |
| `kubectl cluster-info` | Display addresses of the master and services |
| `kubectl get nodes` | List all nodes in the cluster |
| `kubectl get pods` | List all pods in the cluster |
| `kubectl get services` | List all services in the cluster |
| `kubectl get deployments` | List all deployments in the cluster |
| `kubectl get namespaces` | List all namespaces in the cluster |
| `kubectl get events` | List all events in the cluster |

### Resource Management

| Command | Description |
| --- | --- |
| `kubectl apply -f <file>` | Apply a configuration file |
| `kubectl delete -f <file>` | Delete a configuration file |
| `kubectl get <resource>` | List all resources of a type |
| `kubectl describe <resource> <name>` | Describe a resource |
| `kubectl edit <resource> <name>` | Edit a resource |
| `kubectl exec -it <pod> -- <command>` | Execute a command in a pod |

### Pod Management

| Command | Description |
| --- | --- |
| `kubectl run <name> --image=<image>` | Create a new pod |
| `kubectl delete pod <name>` | Delete a pod |
| `kubectl get pod <name>` | Get details of a pod |
| `kubectl describe pod <name>` | Describe a pod |
| `kubectl logs <name>` | Show logs of a pod |
| `kubectl exec -it <name> -- /bin/bash` | Execute a command in a pod |
| `kubectl cp <pod>:<source> <destination>` | Copy files from a pod |
| `kubectl top node` | Show metrics for all nodes |
| `kubectl top pod` | Show metrics for all pods |
| `kubectl top pod <name>` | Show metrics for a specific pod |

### Service Management

| Command | Description |
| --- | --- |
| `kubectl expose pod <name> --port=444 --target-port=555` | Expose a pod as a service |
| `kubectl delete service <name>` | Delete a service |
| `kubectl get service <name>` | Get details of a service |
| `kubectl describe service <name>` | Describe a service |

### Deployment Management

| Command | Description |
| --- | --- |
| `kubectl create deployment <name> --image=<image>` | Create a new deployment |
| `kubectl delete deployment <name>` | Delete a deployment |
| `kubectl get deployment <name>` | Get details of a deployment |
| `kubectl describe deployment <name>` | Describe a deployment |
| `kubectl scale deployment <name> --replicas=3` | Scale a deployment to 3 replicas |
| `kubectl rollout status deployment/<name>` | Check the status of a deployment rollout |
| `kubectl rollout history deployment/<name>` | Show the history of a deployment rollout |
| `kubectl rollout undo deployment/<name>` | Rollback a deployment to the previous version |
| `kubectl rollout undo deployment/<name> --to-revision=1` | Rollback a deployment to a specific revision |

### Namespace Management

| Command | Description |
| --- | --- |
| `kubectl create namespace <name>` | Create a new namespace |
| `kubectl delete namespace <name>` | Delete a namespace |
| `kubectl get namespace <name>` | Get details of a namespace |
| `kubectl describe namespace <name>` | Describe a namespace |

## Helm

### Repository Management

| Command | Description |
| --- | --- |
| `helm repo list` | List Helm repositories |
| `helm repo update` | Update list of Helm charts from repositories |

### Chart Management

| Command | Description |
| --- | --- |
| `helm search` | List all installed charts |
| `helm search <chart>` | Search for a chart |
| `helm ls` | List all installed Helm charts |
| `helm ls --deleted` | List all deleted Helm charts |
| `helm ls --all` | List installed and deleted Helm charts |
| `helm inspect values <repo>/<chart>` | Inspect the variables in a chart |

### Install Delete Helm Charts

| Command | Description |
| --- | --- |
| `helm install --name <name> <repo>/<chart>` | Install a Helm chart |
| `helm install --name <name> --values <VALUES.YML> <repo>/<chart>` | Install a Helm chart and override variables |
| `helm status <name>` | Show status of Helm chart being installed |
| `helm delete --purge <name>` | Delete a Helm chart |

### Upgrading Helm Charts

| Command | Description |
| --- | --- |
| `helm get values <name>` | Return the variables for a release |
| `helm upgrade --values <file> <name> <repo>/<chart>` | Upgrade the chart or variables in a release |
| `helm history <name>` | List release numbers |
| `helm rollback <name> 1` | Rollback to a previous release number |

### Creating Helm Charts

| Command | Description |
| --- | --- |
| `helm create <name>` | Create a blank chart |
| `helm lint <name>` | Lint the chart |
| `helm package <name>` | Package the chart into foo.tgz |
| `helm dependency update` | Install chart dependencies |

## Terraform

### Format and Validate

| Command | Description |
| --- | --- |
| `terraform fmt` | Reformat your configuration in the standard style |
| `terraform validate` | Check whether the configuration is valid |

### Initialize Working Directory

| Command | Description |
| --- | --- |
| `terraform init` | Prepare your working directory for other commands |

### Plan, Deploy and Cleanup

| Command | Description |
| --- | --- |
| `terraform apply --auto-approve` | Create or update infrastructure without confirmation prompt |
| `terraform destroy --auto-approve` | Destroy previously-created infrastructure without confirmation prompt |
| `terraform plan -out plan.out` | Output the deployment plan to plan.out |
| `terraform apply plan.out` | Use the plan.out to deploy infrastructure |
| `terraform plan -destroy` | Outputs a destroy plan |
| `terraform apply -target=aws_instance.myinstance` | Only apply/deploy changes to targeted resource |
| `terraform apply -var myregion=us-east-1` | Pass a variable via CLI while applying a configuration |
| `terraform apply -lock=true` | Lock the state file so it can't be modified |
| `terraform apply refresh=false` | Do not reconcile state file with real-world resources |
| `terraform apply --parallelism=5` | Number of simultaneous resource operations |
| `terraform refresh` | Reconcile the state in Terraform state file with real-world resources |
| `terraform providers` | Get informatino about providers used in the current configuration |

### Workspaces

| Command | Description |
| --- | --- |
| `terraform workspace new <workspace>` | Create a new workspace |
| `terraform workspace select default` | Change to a workspace |
| `terraform workspace list` | List all workspaces |

### State Manipulation

| Command | Description |
| --- | --- |
| `terraform state show aws_instance.myinstance` | Show details stored in the Terraform state file |
| `terraform state pull > terraform.tfstate` | Output Terraform state to a file |
| `terraform state mv aws_iam_role.my_ssm_role module.mymodule` | Move a resource tracked via state to different module |
| `terraform state replace-provider hashicorp/aws registry.custom.com/aws` | Replace an existing provider with another |
| `terraform state list` | List all resources tracked in the Terraform state file |
| `terraform state rm aws_instance.myinstance` | Unmanage a resource, delete it from the Terraform state file |

### Import and Outputs

| Command | Description |
| --- | --- |
| `terraform import <resource_type>.<resource> <id>` | Import a Resource |
| `terraform output` | List all outputs |
| `terraform output <output>` | List a specific output |
| `terraform output -json` | List all outputs in JSON format |

### Terraform Cloud

| Command | Description |
| --- | --- |
| `terraform login` | Login to Terraform Cloud with an API token |
| `terraform logout` | Logout from Terraform Cloud |

## Git

### Repository Management

| Command | Description |
| --- | --- |
| `git init` | Initialize a new Git repository |
| `git clone <url>` | Clone a remote repository |
| `git status` | Show the working tree status |
| `git add <file>` | Add a file to the staging area |
| `git commit -m <message>` | Commit changes to the repository |
| `git push` | Push changes to the remote repository |
| `git pull` | Pull changes from the remote repository |
| `git fetch` | Fetch changes from the remote repository |
| `git merge <branch>` | Merge a branch into the current branch |
| `git branch` | List all branches |
| `git branch <branch>` | Create a new branch |
| `git checkout <branch>` | Switch to a branch |
| `git checkout -b <branch>` | Create and switch to a new branch |
| `git branch -d <branch>` | Delete a branch |
| `git log` | Show commit logs |
| `git diff` | Show changes between commits |
| `git blame <file>` | Show who changed each line in a file |
| `git reflog` | Show a log of changes to HEAD |
| `git reset --hard <commit>` | Reset the repository to a commit |
| `git revert <commit>` | Revert a commit |
| `git stash` | Stash changes in the working directory |
| `git stash pop` | Apply stashed changes to the working directory |
| `git tag <tag>` | Create a tag for a commit |

### Configuration

| Command | Description |
| --- | --- |
| `git config --global user.name <user>` | Set the user name for Git |
| `git config --global user.email <email>` | Set the user email for Git |
| `git config --global core.editor <editor>` | Set the default text editor for Git |
| `git config --global color.ui auto` | Enable colored output for Git |

### Remote Repositories

| Command | Description |
| --- | --- |
| `git remote add <repository> <url>` | Add a remote repository |
| `git remote -v` | List remote repositories |
| `git remote show <repository>` | Show information about a remote repository |
| `git remote rename <repository> <new_repository>` | Rename a remote repository |
| `git remote remove <repository>` | Remove a remote repository |

## OpenSSL

### Certificate Management

| Command | Description |
| --- | --- |
| `openssl req -new -key <key> -out <csr>` | Generate a new certificate signing request |
| `openssl req -x509 -key <key> -in <csr> -out <cert>` | Generate a self-signed certificate |
| `openssl x509 -in <cert> -text -noout` | Display the details of a certificate |
| `openssl x509 -in <cert> -pubkey -noout` | Extract the public key from a certificate |
| `openssl x509 -in <cert> -fingerprint -noout` | Display the fingerprint of a certificate |

### Key Management

| Command | Description |
| --- | --- |
| `openssl genrsa -out <key> 2048` | Generate a new RSA private key |
| `openssl rsa -in <key> -pubout -out <pub_key>` | Extract the public key from a private key |
| `openssl rsa -in <key> -out <new_key>` | Convert a private key to a different format |
| `openssl rand -hex 16` | Generate a random hex string |

### Certificate Signing

| Command | Description |
| --- | --- |
| `openssl ca -in <csr> -out <cert>` | Sign a certificate request |
| `openssl ca -config <config> -in <csr> -out <cert>` | Sign a certificate request with a custom configuration |
| `openssl verify -CAfile <ca> <cert>` | Verify a certificate against a CA file |

### Certificate Conversion

| Command | Description |
| --- | --- |
| `openssl pkcs12 -export -in <cert> -inkey <key> -out <file>` | Convert a certificate and key to PKCS#12 format |
| `openssl pkcs12 -in <file> -out <cert> -nodes` | Extract a certificate and key from a PKCS#12 file |
| `openssl x509 -in <cert> -outform DER -out <file>` | Convert a certificate to DER format |
| `openssl x509 -in <cert> -outform PEM -out <file>` | Convert a certificate to PEM format |

### Encryption and Decryption

| Command | Description |
| --- | --- |
| `openssl enc -aes-256-cbc -salt -in <file> -out <encrypted_file>` | Encrypt a file with AES-256-CBC |
| `openssl enc -d -aes-256-cbc -in <file> -out <decrypted_file>` | Decrypt a file encrypted with AES-256-CBC |
| `openssl dgst -sha256 FILE` | Calculate the SHA-256 hash of a file |
| `openssl dgst -md5 FILE` | Calculate the MD5 hash of a file |

### Miscellaneous

| Command | Description |
| --- | --- |
| `openssl version` | Display the OpenSSL version |
| `openssl s_client -connect <host>:<port>` | Connect to a server using SSL/TLS |
| `openssl s_server -accept <port> -cert <cert> -key <key>` | Start an SSL/TLS server |
| `openssl speed` | Run benchmark tests on OpenSSL algorithms |
| `openssl ciphers -v` | List all available ciphers |
| `openssl rand -base64 32` | Generate a random base64 string |
| `openssl rand -base64 -out <file> 32` | Generate a random base64 string and save it to a file |
| `openssl rand -out <file> 32` | Generate a random binary string and save it to a file |
| `openssl rand -hex 32` | Generate a random hex string |
