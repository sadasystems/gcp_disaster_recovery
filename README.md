# Terraform script to deploy an managed Instance Group with Health check and snapshot schedule 

# Preparing 

## Create two service accounts
In order to execute this script without any GCP keyfile dowloaded, it uses 
impersonnate service account. 
An impersonnate service accout requires twol roles:
`service account token creator` and `service account user roles`.
Along with the impersonnate service account, it requires a service account to create a VM.
This service account requires at least three roles, those are `compute instance admin`, 
`compute network admin` and `compute network user` roles.

reference: https://cloud.google.com/iam/docs/impersonating-service-accounts

## Take images from VM
A VM may have multiple disks. You have to take images of all disks.

reference: https://cloud.google.com/compute/docs/images/create-delete-deprecate-private-images#create_image

## Configuration
Once you have two service accounts and images, you can fill out variables.tfvars file


# execution
To impersonnate a service account, type the command below in the terminal.
Before typing the command, Google Cloud SDK must be installed on your machine.
``` 
 gcloud auth application-default login 
```
Once your machine is authorized by Google, you can run terraform command.
`terraform { init | plan | apply | destroy }`

# Delete the source VM
If a new VM has multiple disks, mount them first.
Restart the new VM and make sure those disks are still mounted.
Check snapshot schedule and health check are created correctly.

If everything is ok, delete the VM migrated from AWS to GCP.

If you run `terraform destory`, it will destroy all resources except the snapshot scheduled and the disks created.
It is correct behavior. You can manually delete disks first then delete the snapshot scheduled from Google Cloud Console UI.

