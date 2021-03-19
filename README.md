# Terraform script to deploy an managed Instance Group with Health check and snapshot schedule 

# Preparing 
In order to execute this script without any GCP keyfile dowloaded, it uses 
impersonnate service account. 
An impersonnate service accout requires twol roles:
`service account token creator` and `service account user roles`.
Along with the impersonnate service account, it requires a service account to create a VM.
This service account requires at least three roles, those are `compute instance admin`, 
`compute network admin` and `compute network user` roles.

After you set up two service account described above, 
VM specification is needed to fill out variables.tfvars file.


# execution
To impersonnate a service account, type the command below in the terminal.
Before typing the command, Google Cloud SDK must be installed on your machine.
``` 
 gcloud auth application-default login 
```
Once your machine is authorized by Google, you can run terraform command.
`terraform { init | plan | apply | destroy }`

# reference
https://cloud.google.com/iam/docs/impersonating-service-accounts


