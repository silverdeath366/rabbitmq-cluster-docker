

Create queues, publish messages, and monitor everything visually.

---
## RabbitMQ Cluster on AWS (Terraform)

Provision a minimal RabbitMQ cluster on AWS using Terraform. This repo creates a VPC, public subnets, security groups, and a small fleet of EC2 instances that auto‑form a RabbitMQ cluster via cloud‑init.

### Architecture
- **VPC and Subnets**: Creates a VPC and N public subnets with DNS support.
- **Security Group**: Ingress for SSH (22), AMQP (5672), and Management UI (15672). Egress open.
- **EC2 Auto‑Cluster**: Launches N EC2 instances and configures RabbitMQ clustering using a bootstrap script.

### What gets created
- VPC, subnets, and routing suitable for public access
- Security group allowing SSH and RabbitMQ ports
- EC2 instances tagged `rabbitmq-node-<index>`
- Output listing RabbitMQ instance IPs

### Repository layout
- `providers.tf`: AWS provider and region
- `main.tf`: Wires VPC, Security, and EC2 modules
- `vpc/`: VPC and subnet resources
- `security/`: Security group resources
- `ec2/`: EC2 instances and `rabbitmq.sh.tpl` bootstrap

Note: If `main.tf` references `./modules/...`, either:
- Move these directories under `modules/` (i.e., `modules/vpc`, `modules/security`, `modules/ec2`), or
- Update `source` paths in `main.tf` to `"./vpc"`, `"./security"`, and `"./ec2"`.

### Prerequisites
- Terraform >= 1.3
- AWS credentials configured (via environment variables, shared credentials, or SSO)
- An existing EC2 key pair in the chosen region (referenced by `key_name`)

### Costs
This will create billable AWS resources (EC2, networking). Destroy when done.

### Quick start
```bash
# 1) Initialize
terraform init

# 2) Review and set variables (recommended via terraform.tfvars)
# Example terraform.tfvars
# region               = "us-east-1"
# vpc_cidr             = "10.0.0.0/16"
# subnet_count         = 2
# ami_id               = "ami-0c55b159cbfafe1f0"   # Example; choose a current Ubuntu in your region
# instance_type        = "t3.micro"
# node_count           = 3
# key_name             = "your-keypair-name"
# allowed_ssh_cidrs    = ["YOUR_IP/32"]
# allowed_rabbitmq_cidrs = ["YOUR_IP/32"]

# 3) Plan
terraform plan

# 4) Apply
terraform apply

# 5) Get instance IPs
terraform output rabbitmq_ips
```

### Variables
- **region**: AWS region; set in `providers.tf` or via variable
- **vpc_cidr**: CIDR for the VPC
- **subnet_count**: Number of public subnets to create
- **ami_id**: AMI for instances (Ubuntu recommended)
- **instance_type**: EC2 type (default `t3.micro`)
- **node_count**: Number of RabbitMQ nodes
- **key_name**: Name of existing EC2 key pair
- **subnet_ids**: Provided internally from VPC module
- **security_group_id**: Provided internally from Security module
- **allowed_ssh_cidrs**: CIDRs allowed for SSH
- **allowed_rabbitmq_cidrs**: CIDRs allowed for AMQP and UI

### Security hardening (important)
- Do not leave `allowed_ssh_cidrs` or `allowed_rabbitmq_cidrs` as `0.0.0.0/0`. Restrict to your IPs.
- Avoid committing real `key_name` values in version control; set via `terraform.tfvars` or environment.
- Consider private subnets with NAT for instances, and a bastion or SSM Session Manager for access.
- For production, configure RabbitMQ users/passwords, TLS, and policies instead of the minimal bootstrap provided here.

### Outputs
- `rabbitmq_ips`: List of instance public IP addresses

### Cleanup
```bash
terraform destroy
```

### Roadmap / ideas
- Private subnets + NAT, ALB/NLB for AMQP/management
- Parametric OS image and bootstrap hardening (users, TLS, credentials)
- Autoscaling group and lifecycle hooks
- CloudWatch metrics and alarms



