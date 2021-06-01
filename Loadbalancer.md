# Loadbalancer setup 
Case 1. An Instance in Managed Instance Group(MIG) - Disaster recovery
- A managed instance group can be a backend for a load balancer

Case 2. An Instance without Instance Group 
To connect an instance with a load balancer, it requires Network Endpoint Group(NEG).
NEG can be a backend of a load balancer. NEG type of backend controls amount of traffic with `rate` per second.
Once you created a NEG, you can add a network endpoint to the NEG.

e.g Terragrunt/Terraform source code. `infrastructure/mmm/qa/mmmapp/test-lb-no-dr` and `modules/attach-load-balancer-on-vm`
You can open `terragrunt.hcl` file under `infrastructure/mmm/qa/mmmapp/test-lb-no-dr` and edit `source_vm` parameter.
This example code will create
 - 1. Network Endpoint Group
 - 2. Network Endpoint for the `source_vm`
 - 3. Load balancer with the backend of the Network Endpoint Group

Case 3. MIG with multiple web endpoints
- create named port for mig
- multiple load balancer?

### virtual machine within a managed instance group
- port name mapping (named port)
- HTTPS proxy (Frontend 443) to HTTP(Backend 80)
- Multiple web services running on different ports

## Reference
https://faun.pub/google-cloud-htp-htps-load-balancer-backend-service-with-multiple-ports-8478ada41ce5