#  Terraform RabbitMQ Cluster on AWS (Docker-Based)

This project provisions a RabbitMQ server on AWS using **Terraform**, **Docker**, and **EC2**, wrapped in a clean and minimal infrastructure-as-code setup.

---

##  Stack

- **Terraform** (Infrastructure as Code)
- **AWS EC2**, VPC, Security Groups
- **Ubuntu 22.04 AMI**
- **Docker-based RabbitMQ** with management UI

---

##  Features

- Single EC2 instance
- RabbitMQ runs inside Docker with management plugin
- SSH access via key pair
- Ports **5672** (AMQP) and **15672** (management UI) exposed
- Easily extensible for multi-node, ASG, or Load Balancer

---

## How to Deploy

```bash
terraform init
terraform apply -auto-approve
```

> ⚠️Make sure your `terraform.tfvars` file includes your AWS key pair name:
> 
> ```hcl
> key_name = "your-existing-keypair"
> ```

---

##  SSH into Your Node

After deploy, get the IP:

```bash
terraform output
```

Then:

```bash
ssh -i your-key.pem ubuntu@<public-ip>
```

---

##  RabbitMQ Access

Once deployed, access the RabbitMQ management UI at:

```
http://<public-ip>:15672
```

**Login:** `guest`  
**Password:** `guest`

Create queues, publish messages, and monitor everything visually.

---




