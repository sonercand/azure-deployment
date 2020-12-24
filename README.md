# Deploying a scalable IaaS web server in Azure
Deploys scalable, customazable azure web server via terraform and packer templates and azure cli.
### Getting Started
1. Clone this repository
2. Create packer image and deploy:
    --a. `az group create -l <location> -n packer-rg`  Replace "<location>".
    --b. cd .\packer\linux_vm_image 
    --c. `packer build server.json` 
    --d. Created image name in azure is "packerLinuxImage"
3. Create and Assign tagging-policy(Optional):<br/>
    Steps below will define and assign a policy that rejects creation of any resource without atleast one tag.
    --a. Start a command line prompt under the directory policies\TagPolicy
    --b. `create_policy_definition.bat` registers policy definition
    --c. `apply_policy.bat` assigns policy
4. Create terraform template and apply:
    --a. Cd .policies\terraform\server
    --b. `terraform init`
    --c. `terraform plan -out <filename>` replace "<filename>"
    --d. `terraform apply <filename>`
    --e. You will be prompted to input:
        -- * VM count : number of virtual machines
        -- * username for virtual machine. Note if VM count is more than 1 then each vm will have an integer suffix.
        -- * password for virtual machine
        -- * prefix: Prefix for main resource names that will be created via this template.
5. How to change predefined template variables:
    vars.tf file contains all the variables used in the template including the ones with a default value such as tag_env, tag_task, and location. These variable can be altered via changing the default values in vars.tf file.
