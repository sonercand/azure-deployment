# Deploying a scalable IaaS web server in Azure
### Overview
This project contains scripts to create infrastucture as code in the form of Terraform template in order to deploy a website with load balancer. Scripts deploy a scalable, customizable azure web server via terraform and packer templates and azure cli. In addition to terraform template it also contains a packer template for a linux web server. The packer image is then used in the terraform template to deploy virtual machines.
In short it can be used to deploy azure virtual machines with load balancer.
Azure components created via main.tf are:
*  resource group that holds all the components
*  virtual network
*  subnet
*  network security group
*  network security rules
*  network interface
*  public ip
*  load balancer
*  availability set
*  virtual machine(s)


### Getting Started
After cloning this repository, solution.plan file can be run via command terminal(detailed steps are below). Only thing that needs to be done other than running solution.plan is to create packer-rg resource group to host the packer image. Note the resource group name has to packer-rg since there is a reference to it within the terraform template but it can simply modified into a variable by using variables.tf file. 
* 1 Clone this repository
* 2 Start command prompt and change directory to terraform\server
* 3 run az group create -l westeurope -n packer-rg
* 4 cd .\packer\linux_vm_image packer build server.json
* 5 run terraform init 
* 6 run terraform apply solution.plan

### Instructions
#### 1. Instruction for packer template, how to create a packer image and how to deploy:
The packer template is saved to server.json file. The server file has instructions for Ubuntu server 18.04-LTS image. Additionally it contains information for azure resource location, virtual machine size and azure tags in builders section. Moreover once it is deployed for demonstration purposes the server runs 

    "echo 'Hello, World!' > index.html"
    
and executes

    "chmod +x {{ .Path }}; {{ .Vars }} sudo -E sh '{{ .Path }}'"
##### how to deploy:
Create the azure resource group. Note: the name should match to the one used in the server.json file as well as to the one refered in terraform template(main.tf).
>Replace azurelocation with an actual azure location. <pre><code>az group create -l azureLocation -n packer-rg </code></pre> 
Change directory in the command prompt to the location of server.json file.
><pre><code>cd .\packer\linux_vm_image</code> </pre> 
Run packer command. Command below will create an image under the packer-rg resource group( If not alread created, the resource group can be created via azure cli: az group create -l westeurope -n packer-rg).
><pre><code>packer build server.json </code></pre> 
>Created resource name under the packer-rg resource group will be "packerLinuxImage" (see server.json file).
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
<p>vars.tf file contains all the variables used in the template including the ones such as tag_env, tag_task, and location. These variable can be altered via changing the default values in vars.tf file.
</p>

### Output

><pre><code> terraform apply solution.plan </code></pre> 
![Apply solution plan](https://github.com/sonercand/azure-deployment/blob/project1/terraform_apply.PNG "Apply Solution.plan")
><pre><code> terraform state list   </code></pre> 
![Statelist](https://github.com/sonercand/azure-deployment/blob/project1/terraform_state_list.PNG "Statelist")
><pre><code> terraform destroy    </code></pre> 
![Destroy](https://github.com/sonercand/azure-deployment/blob/project1/terraform_destroy.PNG "Destroy")

### Dependencies
#### 1. Create an [Azure Account](https://portal.azure.com) 
#### 2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
#### 3. Install [Packer](https://www.packer.io/downloads)
#### 4. Install [Terraform](https://www.terraform.io/downloads.html)
