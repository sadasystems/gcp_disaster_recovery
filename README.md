# Terraform and Terragrunt script to manage infrastructure 

## Preparing
### Install Terraform, Terragrunt and GCP SDK to the machine that runs the command.

https://www.terraform.io/downloads.html

https://terragrunt.gruntwork.io/docs/getting-started/install/

https://cloud.google.com/sdk/docs/install

Terrgrunt is the Terraform wrapper to avoid repeats.

Terragrunt homepage. https://terragrunt.gruntwork.io/

Terragrunt use cases. https://blog.gruntwork.io/terragrunt-how-to-keep-your-terraform-code-dry-and-maintainable-f61ae06959d8

### Directory structure of this project.
Directory structure of this repository reflects the GCP folders and projects structure.
``` 
├── infrastructure
│   ├── mta
│   │   ├── rnd                             <=== folder 
│   │   │   ├── mtaapp                      <=== project 
│   │   │   │   ├── terraform1              <=== VM 
│   │   │   │   │   └── terragrunt.hcl      <=== VM level terragrunt.hcl
│   │   │   │   ├── terraform2
│   │   │   │   │   └── terragrunt.hcl
│   │   │   │   ├── terragrunt.hcl          <=== project level terragrunt.hcl
│   │   │   │   └── vm-no-dr
│   │   │   │       └── terragrunt.hcl
│   │   │   └── terragrunt.hcl
│   │   └── terragrunt.hcl
│   └── terragrunt.hcl
└── modules
    ├── compute-instance                    <=== Terraform code for VM provisioning without disaster recovery
    │   ├── main.tf
    │   ├── output.tf
    │   ├── variables.tf
    │   └── versions.tf
    └── disaster-recovery                   <=== Terraform code for disaster recovery
        ├── data.tf
        ├── main.tf
        ├── output.tf
        ├── provider.tf
        ├── variables.tf
        └── versions.tf
```
### Create two service accounts in the GCP
In order to execute this script without any GCP keyfile dowloaded, it uses 
impersonnate service account. 
An impersonnate service account requires two roles:
`service account token creator` and `service account user roles`.
(If you like to create a load balancer with HTTPS frontend, you need 'loadBalancerAdmin' as well)

The impersonnate service account requires network user permission for the network sub-project at which an instance runs. 
A network sub-project has the prefix 'ent-net-mta-host'.

#### List of roles for an impersonnate service account
For the target project it requires at least 5 roles below.
```
Compute Instance Admin (v1)
Compute Network Admin
Compute Network User
Service Account Token Creator
Service Account User
Compute Load Balancer Admin (optional)
```

For the host network project it requires at least 2 roles below.
``` 
Compute network admin 
compute network user roles
```

Along with the impersonnate service account, it requires a service account for a VM being created.
This service account requires at least two roles, those are `compute network admin` and `compute network user` roles. 
When an application needs to access Google Services,
please, ensure that permissions and roles to access it. 

You can add service accounts information to a project level terragrunt.hcl file.
For example, `infrastructure/mta/rnd/mtaapp/terragrunt.hcl` file.

reference: https://cloud.google.com/iam/docs/impersonating-service-accounts

### Stop the VM to take images out of disks 

A VM may have multiple disks. 
You have to take images of all disks.
Fortunately, this script can take images out of all disks
If your source VM is still running, this automatic process will be halted.

reference: https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images#create_image

### Configuration
Once you have two service accounts and images, you can fill out `terragrunt.hcl` file for a VM.
You can turn on and off external HTTP/HTTPS load balancer. 

## execution
To impersonnate a service account, type the command below in the terminal.
Before typing the command, Google Cloud SDK must be installed on your machine.
``` 
 gcloud auth application-default login 
```

To enable Terraform script calls Google Cloud SDK, type the command below
``` 
 gcloud auth login
```

Before executing the command, creating a directory with the name of the VM and copy `terragrunt.hcl` file from
`terrafor1` or `terraform2`. It ensures that you will create a managed instance group for the VM.
Once copying is done, modify the copied `terragrunt.hcl` file under the directory for your configurations.

Once your machine is authorized by Google, you can run terragrunt command.
`terragrunt { init | plan | apply | destroy | plan-all | apply-all | destroy-all }`

## Clean up - Delete the source VM
If a new VM has multiple disks, mount them first.
Restart the new VM and make sure those disks are still mounted.
Check snapshot schedule and health check are created correctly.

If everything is ok, delete the VM migrated from AWS to GCP.

If you run `terragrunt destory`, it will destroy all resources except the snapshot scheduled and the disks created.
It is correct behavior. You can manually delete disks first then delete the snapshot scheduled from Google Cloud Console UI.

# Terragrunt script for a batch job that affects all VMs in a project

We have multiple VMs that need to have disaster recovery capacity. 

Terraform script applies to a VM only. 

That means a user may run terraform script multiple times. 

Terragrunt can apply the disaster recovery Terraform script to multiple VMs to avoid this repeat.

## Apply Terraform script to all VMs in a project.

1) fill out terragrunt.hcl file under a project level directory. ex, `mtaapp`
   - Put service accounts information.
    
2) fill out terragurnt.hcl file for a VM.
   In this example, names of the VMs are `terraform1` and `terraform2`.
   ex, terragrunt.hcl files under `terraform1` and `terraform2` directories. 

3) run terragrunt script 
- To apply a single VM, move to VM level directory first. For example, `cd terraform1` or `cd terraform2` 
  type the command `terragrunt plan` first and then `terragrunt apply`.
  `terragurnt {init | plan | apply}` is equivalent of terraform command `terraform {init | plan| apply}`
- To apply all the VM in a project, move to the project level directory. For example, `cd mtaapp`.
    type command with `-all` postfix. `terragrunt plan-all` or `terragrunt apply-all`. 
  These commands execute terragrunt for the sub-directory from the current directory the command runs.
  
# VM provisioning without disaster recovery capability

Once service accounts for impersonation and VM are ready, you can deploy a VM without disaster recovery capability.

1) Move to the terragrunt directory for the VM. It is `infrastructure/rnd/mta/vm-no-dr` above example.

2) fill out `terragrunt.hcl` file for your VM. It contains configurations for the VM will be deployed.

3) run `terragrunt init`, `terragrunt plan` and `terragrunt apply` in a row.

You can add a directory under `infrastructure/mta/rnd/mtaapp/` for a new VM if you need to deploy a new VM.

# Adding Google Filestore (NAS, NFS) for a project.

## Create Filestore to the network host project
Filestore is a managed service within GCP. It is easy to create and use.

Since our project uses shared VPC network, Filestore instances must be created in the host network project.
e.g. ent-net-mta-host-fde3 

Once you created a Filestore instance in the host network project, you can access the instance from the service project.
e.g mtaapp. 

Please, review the reference below
https://cloud.google.com/filestore/docs/creating-instances
https://cloud.google.com/filestore/docs/known-issues#no-shared-vpc

## Mount the Filestore share on the VM's directory.

https://cloud.google.com/filestore/docs/mounting-fileshares#mounting_a_file_share_on_a_vm_instance
