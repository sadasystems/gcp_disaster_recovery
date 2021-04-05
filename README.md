# Terraform and Terragrunt script to deploy an managed Instance Group with Health check and snapshot schedule 

## Preparing 
### Install Terraform and Terragrunt to the machine that runs the command.
https://www.terraform.io/downloads.html
https://terragrunt.gruntwork.io/docs/getting-started/install/

### Create two service accounts in the GCP
In order to execute this script without any GCP keyfile dowloaded, it uses 
impersonnate service account. 
An impersonnate service accout requires twol roles:
`service account token creator` and `service account user roles`.
Along with the impersonnate service account, it requires a service account to create a VM.
This service account requires at least three roles, those are `compute instance admin`, 
`compute network admin` and `compute network user` roles.

reference: https://cloud.google.com/iam/docs/impersonating-service-accounts

## Stop the VM to take images out of disks 

A VM may have multiple disks. 
You have to take images of all disks.
Fortunately, this script can take images out of all disks
If your source VM is still running, this automatic process will be halted.

reference: https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images#create_image

## Configuration
Once you have two service accounts and images, you can fill out variables.tfvars file.
You can turn on and off external HTTP/HTTPS load balancer. 

## execution
To impersonnate a service account, type the command below in the terminal.
Before typing the command, Google Cloud SDK must be installed on your machine.
``` 
 gcloud auth application-default login 
```
Once your machine is authorized by Google, you can run terragrunt command.
`terragrunt { init | plan | apply | destroy | plan-all | apply-all | destroy-all }`

## Delete the source VM
If a new VM has multiple disks, mount them first.
Restart the new VM and make sure those disks are still mounted.
Check snapshot schedule and health check are created correctly.

If everything is ok, delete the VM migrated from AWS to GCP.

If you run `terraform destory`, it will destroy all resources except the snapshot scheduled and the disks created.
It is correct behavior. You can manually delete disks first then delete the snapshot scheduled from Google Cloud Console UI.

# Terragrunt script for a batch job that affects all VMs in a project

Terrgrunt is the Terraform wrapper to avoid repeats.
Terragrunt homepage. https://terragrunt.gruntwork.io/
Terragrunt use cases. https://blog.gruntwork.io/terragrunt-how-to-keep-your-terraform-code-dry-and-maintainable-f61ae06959d8

We have multiple VMs that need to have disaster recovery capacity. 
Terraform script applies to a VM only. 
That means a user may run terraform script multiple times. 
Terragrunt can apply the disaster recovery Terraform script to multiple VMs to avoid this repeat.

## Directory structure of this project.
``` 
├── infrastructure
│   ├── rnd                         <=== Folder level
│   │   ├── mta                      <=== Project level
│   │   │   ├── terraform1              <=== VM 1
│   │   │   │   └── terragrunt.hcl      
│   │   │   ├── terraform2              <=== VM 2
│   │   │   │   └── terragrunt.hcl
│   │   │   └── terragrunt.hcl
│   │   └── terragrunt.hcl
│   └── terragrunt.hcl
└── modules                         <=== Terraform script. 
    └── disaster-recovery
        ├── data.tf
        ├── main.tf
        ├── output.tf
        ├── variables.tf
        └── versions.tf

```

## Apply Terraform script to all VMs in a project.

1) fill out terragrunt.hcl file under a project level directory. ex, `mta`
   - Put service accounts information.
    
1) fill out terragurnt.hcl file for a VM.
   In this example, names of the VMs are `terraform1` and `terraform2`.
   ex, terragrunt.hcl files under `terraform1` and `terraform2` directories. 

1) run terragrunt script 
- To apply a single VM, move to VM level directory first. For example, `cd terraform1` or `cd terraform2` 
  type the command `terragrunt plan` first and then `terragrunt apply`.
  `terragurnt {init | plan | apply}` is equivalent of terraform command `terraform {init | plan| apply}`
- To apply all the VM in a project, move to the project level directory. For example, `cd mta`.
    type command with `-all` postfix. `terragrunt plan-all` or `terragrunt apply-all`. 
  These commands execute terragrunt for the sub-directory from the current directory the command runs.
  
