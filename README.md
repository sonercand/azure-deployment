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

Output from terraform apply is below: 


        {
        "version": 4,
        "terraform_version": "0.14.2",
        "serial": 238,
        "lineage": "2b0a798c-4cd3-2e3e-3042-c3717b6dbe82",
        "outputs": {},
        "resources": [
            {
            "mode": "data",
            "type": "azurerm_image",
            "name": "packer-image",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "data_disk": [],
                    "id": "/subscriptions/subscription_id/resourceGroups/packer-rg/providers/Microsoft.Compute/images/packerLinuxImage",
                    "location": "westeurope",
                    "name": "packerLinuxImage",
                    "name_regex": null,
                    "os_disk": [
                    {
                        "blob_uri": "",
                        "caching": "ReadWrite",
                        "managed_disk_id": "/subscriptions/subscription_id/resourceGroups/pkr-Resource-Group-7ca9z0ygir/providers/Microsoft.Compute/disks/pkros7ca9z0ygir",
                        "os_state": "Generalized",
                        "os_type": "Linux",
                        "size_gb": 30
                    }
                    ],
                    "resource_group_name": "packer-rg",
                    "sort_descending": false,
                    "tags": {
                    "env": "test",
                    "task": "Image deployment test"
                    },
                    "timeouts": null,
                    "zone_resilient": false
                },
                "sensitive_attributes": []
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_availability_set",
            "name": "avset",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Compute/availabilitySets/avset",
                    "location": "westeurope",
                    "managed": true,
                    "name": "avset",
                    "platform_fault_domain_count": 2,
                    "platform_update_domain_count": 2,
                    "proximity_placement_group_id": null,
                    "resource_group_name": "test-resources",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_lb",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "frontend_ip_configuration": [
                    {
                        "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/frontendIPConfigurations/PublicIPAddress",
                        "inbound_nat_rules": [],
                        "load_balancer_rules": [],
                        "name": "PublicIPAddress",
                        "outbound_rules": [],
                        "private_ip_address": "",
                        "private_ip_address_allocation": "Dynamic",
                        "private_ip_address_version": "IPv4",
                        "public_ip_address_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/publicIPAddresses/main",
                        "public_ip_prefix_id": "",
                        "subnet_id": "",
                        "zones": null
                    }
                    ],
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main",
                    "location": "westeurope",
                    "name": "main",
                    "private_ip_address": "",
                    "private_ip_addresses": [],
                    "resource_group_name": "test-resources",
                    "sku": "Basic",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_public_ip.main",
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_lb_backend_address_pool",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "backend_ip_configurations": [],
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/backendAddressPools/BackEndAddressPool",
                    "load_balancing_rules": [],
                    "loadbalancer_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main",
                    "name": "BackEndAddressPool",
                    "resource_group_name": "test-resources",
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_lb.main",
                    "azurerm_public_ip.main",
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_linux_virtual_machine",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "index_key": 0,
                "schema_version": 0,
                "attributes": {
                    "additional_capabilities": [],
                    "admin_password": "adch34!3d$;1A",
                    "admin_ssh_key": [],
                    "admin_username": "a45ka",
                    "allow_extension_operations": true,
                    "availability_set_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Compute/availabilitySets/AVSET",
                    "boot_diagnostics": [],
                    "computer_name": "test-0-vm",
                    "custom_data": null,
                    "dedicated_host_id": "",
                    "disable_password_authentication": false,
                    "encryption_at_host_enabled": false,
                    "eviction_policy": "",
                    "extensions_time_budget": "PT1H30M",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Compute/virtualMachines/test-0-vm",
                    "identity": [],
                    "location": "westeurope",
                    "max_bid_price": -1,
                    "name": "test-0-vm",
                    "network_interface_ids": [
                    "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0"
                    ],
                    "os_disk": [
                    {
                        "caching": "ReadWrite",
                        "diff_disk_settings": [],
                        "disk_encryption_set_id": "",
                        "disk_size_gb": 30,
                        "name": "test-0-vm_disk1_aa5d2c7b9ae945cabcae91c81d264a0f",
                        "storage_account_type": "Standard_LRS",
                        "write_accelerator_enabled": false
                    }
                    ],
                    "plan": [],
                    "priority": "Regular",
                    "private_ip_address": "10.0.1.4",
                    "private_ip_addresses": [
                    "10.0.1.4"
                    ],
                    "provision_vm_agent": true,
                    "proximity_placement_group_id": "",
                    "public_ip_address": "",
                    "public_ip_addresses": [],
                    "resource_group_name": "test-resources",
                    "secret": [],
                    "size": "Standard_A2",
                    "source_image_id": "/subscriptions/subscription_id/resourceGroups/packer-rg/providers/Microsoft.Compute/images/packerLinuxImage",
                    "source_image_reference": [],
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "virtual_machine_id": "a361647f-be21-48ba-81f7-6859e9d51797",
                    "virtual_machine_scale_set_id": "",
                    "zone": ""
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_availability_set.avset",
                    "azurerm_network_interface.main",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main",
                    "data.azurerm_image.packer-image"
                ]
                },
                {
                "index_key": 1,
                "schema_version": 0,
                "attributes": {
                    "additional_capabilities": [],
                    "admin_password": "adch34!3d$;1A",
                    "admin_ssh_key": [],
                    "admin_username": "a45ka",
                    "allow_extension_operations": true,
                    "availability_set_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Compute/availabilitySets/AVSET",
                    "boot_diagnostics": [],
                    "computer_name": "test-1-vm",
                    "custom_data": null,
                    "dedicated_host_id": "",
                    "disable_password_authentication": false,
                    "encryption_at_host_enabled": false,
                    "eviction_policy": "",
                    "extensions_time_budget": "PT1H30M",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Compute/virtualMachines/test-1-vm",
                    "identity": [],
                    "location": "westeurope",
                    "max_bid_price": -1,
                    "name": "test-1-vm",
                    "network_interface_ids": [
                    "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1"
                    ],
                    "os_disk": [
                    {
                        "caching": "ReadWrite",
                        "diff_disk_settings": [],
                        "disk_encryption_set_id": "",
                        "disk_size_gb": 30,
                        "name": "test-1-vm_disk1_8340b92dc85e4e159a87a5e68fa731b3",
                        "storage_account_type": "Standard_LRS",
                        "write_accelerator_enabled": false
                    }
                    ],
                    "plan": [],
                    "priority": "Regular",
                    "private_ip_address": "10.0.1.5",
                    "private_ip_addresses": [
                    "10.0.1.5"
                    ],
                    "provision_vm_agent": true,
                    "proximity_placement_group_id": "",
                    "public_ip_address": "",
                    "public_ip_addresses": [],
                    "resource_group_name": "test-resources",
                    "secret": [],
                    "size": "Standard_A2",
                    "source_image_id": "/subscriptions/subscription_id/resourceGroups/packer-rg/providers/Microsoft.Compute/images/packerLinuxImage",
                    "source_image_reference": [],
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "virtual_machine_id": "9822dab7-1ece-4a58-a710-e0a687724792",
                    "virtual_machine_scale_set_id": "",
                    "zone": ""
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_availability_set.avset",
                    "azurerm_network_interface.main",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main",
                    "data.azurerm_image.packer-image"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_interface",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "index_key": 0,
                "schema_version": 0,
                "attributes": {
                    "applied_dns_servers": [],
                    "dns_servers": [],
                    "enable_accelerated_networking": false,
                    "enable_ip_forwarding": false,
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0",
                    "internal_dns_name_label": "",
                    "internal_domain_name_suffix": "hvn0qmga1bnepppt23m54dpzla.ax.internal.cloudapp.net",
                    "ip_configuration": [
                    {
                        "name": "internal",
                        "primary": true,
                        "private_ip_address": "10.0.1.4",
                        "private_ip_address_allocation": "Dynamic",
                        "private_ip_address_version": "IPv4",
                        "public_ip_address_id": "",
                        "subnet_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/virtualNetworks/test-network/subnets/test-subnet"
                    }
                    ],
                    "location": "westeurope",
                    "mac_address": "",
                    "name": "nic-0",
                    "private_ip_address": "10.0.1.4",
                    "private_ip_addresses": [
                    "10.0.1.4"
                    ],
                    "resource_group_name": "test-resources",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "virtual_machine_id": ""
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                },
                {
                "index_key": 1,
                "schema_version": 0,
                "attributes": {
                    "applied_dns_servers": [],
                    "dns_servers": [],
                    "enable_accelerated_networking": false,
                    "enable_ip_forwarding": false,
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1",
                    "internal_dns_name_label": "",
                    "internal_domain_name_suffix": "hvn0qmga1bnepppt23m54dpzla.ax.internal.cloudapp.net",
                    "ip_configuration": [
                    {
                        "name": "internal",
                        "primary": true,
                        "private_ip_address": "10.0.1.5",
                        "private_ip_address_allocation": "Dynamic",
                        "private_ip_address_version": "IPv4",
                        "public_ip_address_id": "",
                        "subnet_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/virtualNetworks/test-network/subnets/test-subnet"
                    }
                    ],
                    "location": "westeurope",
                    "mac_address": "",
                    "name": "nic-1",
                    "private_ip_address": "10.0.1.5",
                    "private_ip_addresses": [
                    "10.0.1.5"
                    ],
                    "resource_group_name": "test-resources",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "virtual_machine_id": ""
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_interface_backend_address_pool_association",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "index_key": 0,
                "schema_version": 0,
                "attributes": {
                    "backend_address_pool_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/backendAddressPools/BackEndAddressPool",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0/ipConfigurations/internal|/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/backendAddressPools/BackEndAddressPool",
                    "ip_configuration_name": "internal",
                    "network_interface_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0",
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_lb.main",
                    "azurerm_lb_backend_address_pool.main",
                    "azurerm_network_interface.main",
                    "azurerm_public_ip.main",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                },
                {
                "index_key": 1,
                "schema_version": 0,
                "attributes": {
                    "backend_address_pool_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/backendAddressPools/BackEndAddressPool",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1/ipConfigurations/internal|/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/loadBalancers/main/backendAddressPools/BackEndAddressPool",
                    "ip_configuration_name": "internal",
                    "network_interface_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1",
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_lb.main",
                    "azurerm_lb_backend_address_pool.main",
                    "azurerm_network_interface.main",
                    "azurerm_public_ip.main",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_interface_security_group_association",
            "name": "nic_sec_assoc",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "index_key": 0,
                "schema_version": 0,
                "attributes": {
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0|/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg",
                    "network_interface_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-0",
                    "network_security_group_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg",
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_network_interface.main",
                    "azurerm_network_security_group.network_security_group",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                },
                {
                "index_key": 1,
                "schema_version": 0,
                "attributes": {
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1|/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg",
                    "network_interface_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkInterfaces/nic-1",
                    "network_security_group_id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg",
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_network_interface.main",
                    "azurerm_network_security_group.network_security_group",
                    "azurerm_resource_group.main",
                    "azurerm_subnet.internal",
                    "azurerm_virtual_network.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_security_group",
            "name": "network_security_group",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg",
                    "location": "westeurope",
                    "name": "test-nsg",
                    "resource_group_name": "test-resources",
                    "security_rule": [],
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_security_rule",
            "name": "allow_subnet_traffic",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "access": "Allow",
                    "description": "",
                    "destination_address_prefix": "*",
                    "destination_address_prefixes": null,
                    "destination_application_security_group_ids": null,
                    "destination_port_range": "*",
                    "destination_port_ranges": null,
                    "direction": "Inbound",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg/securityRules/test-allow_subnet_traffic",
                    "name": "test-allow_subnet_traffic",
                    "network_security_group_name": "test-nsg",
                    "priority": 101,
                    "protocol": "*",
                    "resource_group_name": "test-resources",
                    "source_address_prefix": "10.0.1.0/24",
                    "source_address_prefixes": null,
                    "source_application_security_group_ids": null,
                    "source_port_range": "*",
                    "source_port_ranges": null,
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_network_security_group.network_security_group",
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_network_security_rule",
            "name": "deny_inbound_internet",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "access": "Deny",
                    "description": "",
                    "destination_address_prefix": "VirtualNetwork",
                    "destination_address_prefixes": null,
                    "destination_application_security_group_ids": null,
                    "destination_port_range": "*",
                    "destination_port_ranges": null,
                    "direction": "Inbound",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/networkSecurityGroups/test-nsg/securityRules/test-deny_inbound_internet",
                    "name": "test-deny_inbound_internet",
                    "network_security_group_name": "test-nsg",
                    "priority": 102,
                    "protocol": "*",
                    "resource_group_name": "test-resources",
                    "source_address_prefix": "Internet",
                    "source_address_prefixes": null,
                    "source_application_security_group_ids": null,
                    "source_port_range": "*",
                    "source_port_ranges": null,
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_network_security_group.network_security_group",
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_public_ip",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "allocation_method": "Static",
                    "domain_name_label": null,
                    "fqdn": null,
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/publicIPAddresses/main",
                    "idle_timeout_in_minutes": 4,
                    "ip_address": "13.73.182.124",
                    "ip_version": "IPv4",
                    "location": "westeurope",
                    "name": "main",
                    "public_ip_prefix_id": null,
                    "resource_group_name": "test-resources",
                    "reverse_fqdn": null,
                    "sku": "Basic",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "zones": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_resource_group",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources",
                    "location": "westeurope",
                    "name": "test-resources",
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null
                },
                "sensitive_attributes": [],
                "private":"private_key",
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_subnet",
            "name": "internal",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "address_prefix": "10.0.1.0/24",
                    "address_prefixes": [
                    "10.0.1.0/24"
                    ],
                    "delegation": [],
                    "enforce_private_link_endpoint_network_policies": false,
                    "enforce_private_link_service_network_policies": false,
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/virtualNetworks/test-network/subnets/test-subnet",
                    "name": "test-subnet",
                    "resource_group_name": "test-resources",
                    "service_endpoint_policy_ids": null,
                    "service_endpoints": null,
                    "timeouts": null,
                    "virtual_network_name": "test-network"
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main",
                    "azurerm_virtual_network.main"
                ]
                }
            ]
            },
            {
            "mode": "managed",
            "type": "azurerm_virtual_network",
            "name": "main",
            "provider": "provider[\"registry.terraform.io/hashicorp/azurerm\"]",
            "instances": [
                {
                "schema_version": 0,
                "attributes": {
                    "address_space": [
                    "10.0.0.0/16"
                    ],
                    "bgp_community": "",
                    "ddos_protection_plan": [],
                    "dns_servers": null,
                    "guid": "30a85b3d-d8c0-475a-bdf3-e759ff0df958",
                    "id": "/subscriptions/subscription_id/resourceGroups/test-resources/providers/Microsoft.Network/virtualNetworks/test-network",
                    "location": "westeurope",
                    "name": "test-network",
                    "resource_group_name": "test-resources",
                    "subnet": [],
                    "tags": {
                    "env": "test",
                    "task": "test"
                    },
                    "timeouts": null,
                    "vm_protection_enabled": false
                },
                "sensitive_attributes": [],
                "private":"private_key",
                "dependencies": [
                    "azurerm_resource_group.main"
                ]
                }
            ]
            }
        ]
        }




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
