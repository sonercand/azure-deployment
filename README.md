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
After cloning this repository, solution.plan file can be run via command terminal(detailed steps are below). Only thing that needs to be done other than running solution.plan is to create packer-rg resource group to host the packer image. Note the resource group name has to packer-rg since there is a reference to it within the terraform template but it can simply modified into a variable by using vars.tf file. 
* 1 Clone this repository
* 2 Start command prompt and change directory to terraform\server
* 3 run az group create -l westeurope -n packer-rg
* 4 cd .\packer\linux_vm_image packer build server.json
* 5 run terraform init 
* 6 run terraform apply solution.plan

### Instructions
#### 1. Instruction for packer template, how to create an azure virtual machine image with packer and how to deploy:
The packer template is saved to server.json file. The server file has instructions for Ubuntu server 18.04-LTS image. Additionally it contains information for azure resource location, virtual machine size and azure tags in builders section. Moreover once it is deployed server runs the demo inline code below: 

    "echo 'Hello, World!' > index.html"
    
also executes:

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
#### 3. Instructions for Terraform template: How to run the template and customize its parameters:
Terraform template is saved to main.tf file. In the same folder there are also vars.tf and solution.plan files. main.tf file contains the main template which contains the instructions for the virtual machines, virtual network, security group as well as load balancer. main.tf file contains predefined parameters such as location (azure resource location e.g. west europe), tag_env and tag_task (predefined azure tags that will be attached every resource that will be created via terraform template), vm_count(the number of vms that will be created) etc. These parameters can be customised using the vars.tf file. solution.plan file is a ready to deploy plan with the current predefined parameters.
Running terraform template:
* Change directory to location of main.tf file.

      Cd .policies\terraform\server 
    
* Initiate terraform

      terraform init 
    
* Save a terraform deployment plan (It will display any pre-deployment errors at this stage). The samplefilename can be modified to a more meaninful name.

      terraform plan -out samplefilename 

* Deploy using the out filename chosen at the previous step

      terraform apply samplefilename

##### How to customize predefined template variables:
The vars.tf file contains all the configurable input variables used in the template. These are prefix, tag_env, tag_task, vm_count, location, username and password. 
These variables serve as parameters providing a customizable template without the need to alter the source code. The default argument for all these variable are set  within the vars.tf therefore they are rendered as optional. Please see [terraform input variables documentation](https://www.terraform.io/docs/configuration/variables.html) for more information.
If no option is set, running terraform plan or terraform apply commands will create a plan and apply that plan with the default variable values. However by appending -var="variableName=variableValue" to terraform plan or terraform apply command, the default values can be altered.


     terraform apply -var="vm_count=3"

Alternatively varibles can be set using a variable file that contains only variable name assignments.  Example variables.tfvars file: 

      prefix = "tf"
      vm_count = 3
      location = "westeurope"

Apply using variables.tfvars file:

      terraform apply -var-file="variables.tfvars"

### Output

terraform apply solution.plan command output: 
![Apply solution plan](https://github.com/sonercand/azure-deployment/blob/project1/terraform_apply.PNG "Apply Solution.plan")
terraform state list 
![Statelist](https://github.com/sonercand/azure-deployment/blob/project1/terraform_state_list.PNG "Statelist")
><pre><code> terraform destroy    </code></pre> 
![Destroy](https://github.com/sonercand/azure-deployment/blob/project1/terraform_destroy.PNG "Destroy")

### Dependencies
#### 1. Create an [Azure Account](https://portal.azure.com) 
#### 2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
#### 3. Install [Packer](https://www.packer.io/downloads)
#### 4. Install [Terraform](https://www.terraform.io/downloads.html)
