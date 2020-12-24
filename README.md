# Deploying a scalable IaaS web server in Azure
<p>Deploys scalable, customazable azure web server via terraform and packer templates and azure cli.</p>

### Getting Started
#### 1. Clone this repository
#### 2. Start command prompt and change directory to terraform\server
#### 3. run az group create -l westeurope -n packer-rg
#### 4. >cd .\packer\linux_vm_image packer build server.json
#### 5. run terraform init 
#### 6. run terraform apply solution.plan
### Instructions
#### 1. Create packer image and deploy:
>Replace azurelocation with an actual azure location. <pre><code>az group create -l azureLocation -n packer-rg </code></pre> <br/>
>Change directory to where server.json is located. <pre><code>cd .\packer\linux_vm_image</code> </pre> <br/>
><pre><code>packer build server.json </code></pre> <br/>
>Created resource name under the packer-rg resource group will be "packerLinuxImage"
#### 2. Create and Assign tagging-policy(Optional): </li>
> Steps below will define and assign a policy that rejects creation of any resource without atleast one tag.
>Register policy definition.  <pre><code>Start a command line prompt under the directory policies\TagPolicy</code> </pre> 
> Create a policy definition <pre><code>create_policy_definition.bat</code></pre>
> <pre><code>az policy definition list</code></pre> 
> ![Policy definition](https://github.com/sonercand/azure-deployment/blob/project1/tagging_policy_definition.PNG "Created Azure Policy definition")
> Assign policy <pre><code>apply_policy.bat</code></pre> 
> <pre><code>az policy assignment list</code></pre> 
> ![Policy assignment](https://github.com/sonercand/azure-deployment/blob/project1/tagging_policy_assignment.PNG "Created Azure Policy assignment")
#### 3. Create terraform template and apply:
><pre><code>Cd .policies\terraform\server</code></pre> 
><pre><code>terraform init</code></pre> 
>Replace filename with any name.<pre><code>terraform plan -out filename </code></pre> 
><pre><code>terraform apply filename</code></pre> 
>You will be prompted to input:
> ##### VM count : number of virtual machines
> ##### username: for virtual machine. Note if VM count is more than 1 then each vm will have an integer suffix.
> ##### password: for virtual machine.
> ##### prefix: Prefix for main resource names that will be created via this template.
#### 4. How to change predefined template variables:
<p>vars.tf file contains all the variables used in the template including the ones such as tag_env, tag_task, and location. These variable can be altered via changing the default values in vars.tf file.</p>
### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)