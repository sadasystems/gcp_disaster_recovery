# OS Patch management
Required permission for impersonate service account 

role : patch deployment admin

permission: osconfig.patchDeployments.create

1. You can set up OS patch management for all VMs or a specific VM in a project 
by setting up metadata value [reference](https://cloud.google.com/compute/docs/manage-os#console_1)
   
2. Service agent [reference](https://cloud.google.com/compute/docs/vm-manager#service-agent) 

3. Enable the OS config service API [reference](https://cloud.google.com/compute/docs/manage-os#enable-service-api)

4. Check the OS Config agent is installed. If you set up the metadata, the agent will be installed on the VM.