# IaC for GCP using Terraform

[![TF for GCP Infra](https://github.com/cyse7125-fall2023-group05/tf-gcp-org/actions/workflows/gcp-tf-validate.yml/badge.svg?branch=master)](https://github.com/cyse7125-fall2023-group05/tf-gcp-org/actions/workflows/gcp-tf-validate.yml)

Set up infrastructure in `Google Cloud Platform (GCP)` to be able to launch a Kubernetes cluster and various other resources using Hashicorp `Terraform`.

## :arrow_heading_down: Installation

### :package: Install HCP Terraform

Install Terraform using Homebrew (only on MacOS):

> For any other distros, please follow the [setup guide in the official docs](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform).

- First, install the HashiCorp tap, a repository of all our Homebrew packages.

```bash
brew tap hashicorp/tap
```

- Now, install Terraform with `hashicorp/tap/terraform`.

```bash
# This installs a signed binary and is automatically updated with every new official release.
brew install hashicorp/tap/terraform
```

- To update to the latest version of Terraform, first update Homebrew.

```bash
brew update
```

- Then, run the upgrade command to download and use the latest Terraform version.

```bash
brew upgrade hashicorp/tap/terraform
```

### :white_check_mark: Verify Terraform Installation

Verify that the installation worked by opening a new terminal session and listing Terraform's available subcommands.

```bash
terraform -help
```

- Add any subcommand to terraform -help to learn more about what it does and available options.

```bash
terraform -help plan
```

> NOTE: If you get an error that `terraform` could not be found, your `PATH` environment variable was not set up properly. Please go back and ensure that your `PATH` variable contains the directory where Terraform was installed.

### :+1: Enable Terraform tab completion

- If you use either Bash or Zsh, you can enable tab completion for Terraform commands. To enable autocomplete, first ensure that a config file exists for your chosen shell.

```bash
# bash
touch ~/.bashrc
# zsh
touch ~/.zshrc
```

- Install the autocomplete package

```bash
terraform -install-autocomplete
```

### :package: Install GCP CLI

Install GCP CLI using Homebrew (only on MacOS):

> For any other distros, please follow the [setup guide in the official docs](https://cloud.google.com/sdk/docs/install).

```bash
brew install --cask google-cloud-sdk
```

### :white_check_mark: Verify GCP CLI Installation

Verify that the installation worked by opening a new terminal session and listing the `gcloud` version.

```bash
gcloud version
```

### :+1: Enable GCP tab completion

- If you use either Bash or Zsh, you can enable tab completion for Terraform commands. To enable autocomplete, first ensure that a config file exists for your chosen shell.
- The commands below also add `gcloud` to your `PATH` environment variable.

> NOTE: The commands below are specific to the MacOS.

```bash
# add `gcloud` to path
source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc'
# enable tab auto-complete
source '/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc'
```

### 🏢 Configure GCP organization

The prerequisite for GCP to work with organizations is that we need to have a registered `<domain>.tld` which will be used as the `organization`.
We can then create folders, sub-folders, projects and assign IAM roles to these projects, or make projects inherit roles and policies through inheritance from the organization.

In order to setup and get working with organizations for Google Cloud, we need to perform the below mentioned steps:

- Login to your GCP console using your `personal gmail account` (the one you have used to create a GCP account).
- Go to [Identity and Organization](https://console.cloud.google.com/iam-admin/cloudidentity/consumer). Here you will be asked to perform a [checklist](https://console.cloud.google.com/cloud-setup/overview) in order to start using organizations.

> Remember, we need to have a `<domain>.tld` in order to perform the coming steps.

- To use Google Cloud, you must use a Google identity service (either [Cloud Identity](https://cloud.google.com/identity/docs/overview?hl=en_GB) or [Workspace](https://workspace.google.com/) ) to administer credentials for users of your Google Cloud resources. Both Cloud Identity and Workspace provide authentication credentials allowing others to access your cloud resources.
- After establishing the Google identity service, you will use it to verify your domain. Verifying your domain automatically creates an [organization resource](https://cloud.google.com/resource-manager/docs/creating-managing-organization?hl=en_GB) , which is the root node of your Google Cloud resource hierarchy.
- Perform the steps to [setup cloud identity and verify your domain](https://workspace.google.com/signup/gcpidentity/welcome).

> In our case, we will be using the `gcp.<domain>.tld` as the domain to verify with `google cloud identity`, which requires us to add a `TXT` record with our `<domain>.tld` manager. We are managing the `<domain>.tld` on `AWS Route53`, so we will add the `gcp.<domain>.tld` `TXT` record in AWS, which will help Google Cloud verify the domain.
> NOTE: There are multiple additional steps that can be configured that Google recommends, to be setup when working with organizations. For our purposes and use-case, we will stick to only this setup (for now).

### 🔩 Service Accounts

A service account represents a Google Cloud service identity, such as code running on Compute Engine VMs, App Engine apps or systems running outside Google.
We will create and use a service account to setup our infra using Terraform.

> NOTE: While granting policies to a service account, we will be doing that at the organization level, and pass down the policies to this service account via inheritance.

- In order to create a service account, we need to have a `project`, so we will create a `dev` folder within `gcp.<domain>.tld` org with the project name `tf-dev-001` (or any project name you like).
- Go to `IAM and Admin` -> [`Service Accounts`](https://console.cloud.google.com/iam-admin/serviceaccounts).
- Create a service account following the steps mentioned in the GCP console.
- Once the service account is created, we need to create service account keys. Go to the service account you created and click on the `keys` tab. In there, click on `ADD KEY`, which will then download a `json` file with the service account keys.
- To use the service account, save the service account keys JSON file to `~/.config/gcloud/<service-account-keys>.json`.
- Configure the GCP CLI account to use these keys:

> NOTE: These keys are required to be confidential, in case they are leaked or compromised, you need to delete them and create new keys from the console.

```bash
# Configure service account in GCP CLI : https://serverfault.com/a/901950
gcloud auth activate-service-account --key-file=<service-account-keys>.json
# check active gcloud configurations
gcloud config configurations list
# login to authenticate application-default GCP account
gcloud auth application-default login
```

> **Token Caching**: If you have been running Terraform commands for a long time, you may want to clear any cached tokens on your machine, as they can become invalid over time. To avoid token caching, we need to run the application default login command: `gcloud auth application-default login`.

### 🔏 Policies

We will have to provide organization level roles that will be inherited by the service account and the root user.

> All permission we provide will be given to the `organization principal`, i.e., `gcp.<domain>.tld`.

Here's a list of required roles:

- `gcp.<domain>.tld`:
  - `Billing Account Creator`
  - `Organization Administrator`
  - `Organization Policy Administrator`
  - `Project Creator`
- root user:
  - `Folder Admin`
  - `Organization Administrator`
- service account:
  - `Editor`
  - `Folder Admin`
  - `Project Creator`

### 💻 SSH into Compute Instance

To `ssh` into the VM instance, we will have to add the public SSH key into the project [`metadata`](https://console.cloud.google.com/compute/metadata).
This can also be [done via Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_project_metadata.html#example-usage---adding-an-ssh-key).

> A key set in project metadata is propagated to every instance in the project.
This resource configuration is prone to causing frequent diffs as Google adds SSH Keys when the SSH Button is pressed in the console.
It is better to use OS Login instead.

1. Using project metadata resource

```tf
/*
A key set in project metadata is propagated to every instance in the project.
This resource configuration is prone to causing frequent diffs as Google adds SSH Keys when the SSH Button is pressed in the console.
It is better to use OS Login instead.
*/
resource "google_compute_project_metadata" "my_ssh_key" {
  metadata = {
    ssh-keys = <<EOF
      dev:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT dev
      foo:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILg6UtHDNyMNAh0GjaytsJdrUxjtLy3APXqZfNZhvCeT bar
    EOF
  }
}
```

2. Using instance metadata resource

```tf
resource "google_compute_instance" "vm" {
    metadata = {
      ssh-keys = "username:${file("~/.ssh/<ssh-key>.pub")}"
  }
}
```

> NOTE: We can also send a file in the `ssh-keys` metadata instead of plain-text public ssh key file.

3. OS Login at User level (recommended method)

Follow the [Terraform documentation on OS login](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/os_login_ssh_public_key) on how to setup the `google_os_login_ssh_public_key` resource. Once complete, we need to add the metadata `enable-oslogin` property to `TRUE` to enable user login using SSH.
> To use OS login, we need to create the infrastructure on Terraform using the `application-default user`.

```tf
resource "google_compute_instance" "vm" {
  metadata = {
    # Enable os-login through metadata
    enable-oslogin : "TRUE"
  }
}
```

> NOTE: Since we do not set a default username with OS login, we need to use `USERNAME_DOMAIN_SUFFIX` to ssh into the VM.
[Reference](https://cloud.google.com/compute/docs/oslogin/set-up-oslogin#connect_to_vms_that_have_os_login_enabled)

#### Generate the SSH key locally

To generate the ssh key locally on your workstation, use the following command:

> NOTE: It is recommended that you create and store the SSH keys in `~/.ssh` directory

```bash
# follow the on-screen steps after running the command
# avoid adding a passphrase
ssh-keygen -t rsa -b 2048 -C <username>
```

Once the public SSH key has been added to the VM instance metadata, we can use the `external IP` to connect to the VM instance.
Use the below command to connect to the instance:

```bash
ssh -i <path-to-private-key> <username>@<external-ip>
# if os login is enabled:
ssh -i <path-to-private-key> <USERNAME_DOMAIN_SUFFIX>@<external-ip>
# example: ssh -i ~/.ssh/gcp-compute.pub root_gcp_sydrawat_me@34.74.250.180
```

### 🕹️ Enabling APIs

In order to create resources on GCP, we will have to enable some basic APIs. This can be done via Terraform.

Below is a non-exhaustive list of APIs that can come in handy:

- `compute.googleapis.com`
- `storage.googleapis.com`
- `container.googleapis.com`
- `orgpolicy.googleapis.com`

> NOTE: Remember to add timed delays (using `time_sleep` resource) to the GCP resources when creating them via Terraform.

## :wrench: Working with Terraform

1. Initialize Terraform
   This installs the required providers and other plugins for our infrastructure.

   ```bash
   # run in the `root` dir
   terraform init
   ```

2. Create a `<filename>.tfvars` using the `example.tfvars` template.

3. Validate the terraform configuration

   ```bash
   terraform validate
   ```

4. Plan the cloud infrastructure
   This command shows how many resources will be created, deleted or modified when we run `terraform apply`.

   > NOTE: Remember to set your aws profile in the terminal to run the commands going forward

   ```bash
   export AWS_PROFILE=root
   terraform plan -var-file="<filename>.tfvars"
   ```

5. Apply the changes/updates to the infrastructure to create it

   ```bash
   # execute the tf plan
   # `--auto-approve` is to prevent tf from prompting you to say y/n to apply the plan
   terraform apply --auto-approve -var-file="<filename>.tfvars"
   ```

6. To destroy your infrastructure, use the command:

   ```bash
   terraform destroy --auto-approve -var-file="<filename>.tfvars"
   ```

## :file_cabinet: Terraform Backend

> NOTE: This is the recommended best practice.

This is a storage location within GCP from where we access out `.tfstate` file.

> All the information about the infrastructure resources are defined in the `.tfstate` file when we run `terraform apply`. So next time when we run `terraform apply`, it will only compare the *desired state* to the *actual state*.

If we do not use a `backend` to store our `.tfstate` file, it is stored locally on a server (if we provision our infrastructure through a server) or on our local development workstation. The `.tfstate` file may also contain confidential credentials. In order to avoid these problems, it is recommended to use the terraform `backend` to store the `.tfstate` file.

Now, when we run the `terraform apply` command, the `.tfstate` will be accessed through the storage bucket.

> NOTE: The terraform `backend` does not allow the use of tfvars, so we hardcode these values in the configuration.

```tf
# https://developer.hashicorp.com/terraform/language/settings/backends/gcs
terraform {
  backend "gcs" {
    bucket  = "tf-state-prod"
    prefix  = "terraform/state"
  }
}
```

## Google Kubernetes Engine

To run the kubernetes cluster on Google Kubernetes Engine, we use the [`google_container_cluster`](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster) resource to define the cluster configurations.

> To provision a GKE cluster on Google Cloud, refer [here](https://learn.hashicorp.com/tutorials/terraform/gke?in=terraform/kubernetes&utm_source=WEBSITE&utm_medium=WEB_IO&utm_offer=ARTICLE_PAGE&utm_content=DOCS).
> See the [Using GKE with Terraform](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/using_gke_with_terraform) guide for more information about using GKE with Terraform.

Once the setup is configured, we need to connect to the bastion host in order to interact with the private GKE cluster. Follow the steps mentioned below in order to connect to the `bastion host` via your local terminal:

- Install the google `gke-cloud-auth-plugin` locally:

```bash
# assuming you already have the gcloud-sdk installed:
gcloud components install gke-gcloud-auth-plugin
```

- Get the cluster configuration to be written into `~/.kube/config`:

```bash
gcloud container clusters get-credentials primary \
    --region=<your-gke-region> \
    --project=<your-gke-project-name>
```

- Connect to the tunnel via SSH:

```bash
ssh -i ~/.ssh/<private-key> <username>@<compute-instance-ip> -L 8888:127.0.0.1:8888 -N -q -f
```

- Configure `HTTPS_PROXY` to point to `localhost:8888`:

```bash
export HTTPS_PROXY=localhost:8888
```

- Confirm connection to the GKE cluster:

```bash
kubectl get all
kubectl get ns
```

### [Kubectl Auth in GKE v1.26](https://cloud.google.com/blog/products/containers-kubernetes/kubectl-auth-changes-in-gke)

Following the latest changes to the standard GKE cluster, kubectl authentication has changes in GKE v1.26, starting which, users will have to install a new kubectl plugin called **"gke-gcloud-auth-plugin"**.

Existing versions of kubectl and custom Kubernetes clients contain provider-specific code to manage authentication between the client and Google Kubernetes Engine. Starting with v1.26, this code will no longer be included as part of the OSS kubectl. GKE users will need to download and use a separate authentication plugin to generate GKE-specific tokens. This new binary, `gke-gcloud-auth-plugin`, uses the [Kubernetes Client-go Credential Plugin](https://kubernetes.io/docs/reference/access-authn-authz/authentication/#client-go-credential-plugins) mechanism to extend kubectl’s authentication to support GKE. Because plugins are already supported by kubectl, you can switch to the new mechanism now, before v1.26 becomes available.

Below are the installation instructions and technical details of this new binary.

### Kubectl authentication plugin installation instructions

You will need to install the gke-gcloud-auth-plugin binary on all systems where kubectl or Kubernetes custom clients are used.

#### Install using "apt-get install" for DEB based systems

> **NOTE**: Customers using `apt-get install` may need to set up [Google Cloud-Sdk repository source](https://cloud.google.com/sdk/docs/install#deb), if not already set for other [CLOUD-SDK component installations](https://cloud.google.com/sdk/docs/components#external_package_managers).

- Before installing the kubectl auth plugin, make sure that your operating system meets the following requirements:

```bash
# make sure the Ubuntu/Debian image has not reached it's end of life.
# recently updated packages
sudo apt-get update -y
# make sure`apt-transport-https` and `sudo` are installed
sudo apt-get install apt-transport-https ca-certificates gnupg curl sudo -y
```

- Install the Google Cloud-Sdk repository soource:

```bash
# For newer distributions (Debian 9+ or Ubuntu 18.04+) run the following command:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo \
  gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

# For older distributions, run the following command:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo \
  apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# If your distribution's apt-key command doesn't support the --keyring argument, run the following command:
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
```

- Add the gcloud CLI distribution URI as a package source

```bash
# For newer distributions (Debian 9+ or Ubuntu 18.04+), run the following command
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | sudo \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# For older distributions that don't support the signed-by option, run the following command:
echo "deb https://packages.cloud.google.com/apt cloud-sdk main" | sudo \
  tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
```

> **NOTE**: Make sure you don't have duplicate entries for the **cloud-sdk** repo in **/etc/apt/sources.list.d/google-cloud-sdk.list**.

- Finally, run the following command to install the plugin:

```bash
sudo apt-get update -y
sudo apt-get install google-cloud-sdk-gke-gcloud-auth-plugin -y
```
