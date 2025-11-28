# terraform-ecs-capstone-Deepak-Khaja-Khan

Deploying a Containerized Spring Boot Application on AWS using Terraform and ECS

Project Overview
This project demonstrates how to deploy a Java Spring Boot application containerized with Docker on AWS ECS using Fargate, with infrastructure provisioned via Terraform.

Key Features:

Scalable, secure, repeatable setup using Terraform

Application Load Balancer (ALB) for public access

ECS Fargate tasks running container from Docker Hub

VPC with public and private subnets

Terraform outputs for ALB DNS, ECS cluster name, and desired tasks

Project Structure
terraform-ecs-project/
├── main.tf
├── variables.tf
├── provider.tf
├── vpc.tf
├── ecs.tf
├── alb.tf
├── outputs.tf

provider.tf
Purpose: Configure AWS provider to allow Terraform to communicate with AWS.
Explanation:

Tells Terraform to use AWS as the cloud provider

region specifies the AWS region where all resources will be deployed

variables.tf
Purpose: Define reusable variables for the project to make it flexible and environment-independent.
Explanation:

aws_region: AWS region (Mumbai)

environment: Prefix used to dynamically name resources (e.g., dev, prod)

vpc.tf
Purpose: Create networking components for the application.
Key resources:

VPC – Isolated network for the application

Public Subnets – For Application Load Balancer (internet-facing)

Private Subnets – For ECS Fargate tasks (not directly accessible from the internet)

Internet Gateway – Allows public subnets to access the internet

NAT Gateway – Allows private subnets to pull Docker images or access external resources

Route Tables & Security Groups – Control traffic flow and secure the environment

ecs.tf
Purpose: Deploy ECS Fargate infrastructure.
Key resources:

ECS Cluster – Logical container grouping

Task Definition – Defines container image, CPU, memory, ports

ECS Service – Runs multiple tasks, connects to ALB, ensures high availability

alb.tf
Purpose: Configure Application Load Balancer for public access.
Key resources:

ALB – Internet-facing load balancer to distribute traffic

Target Group – Directs requests to ECS Fargate tasks

Listener – Listens on port 80 and forwards requests to target group

outputs.tf
Purpose: Display key outputs after Terraform deployment.
Explanation:

alb_dns_name → Public endpoint for Postman or browser

ecs_cluster_name → ECS cluster identification

ecs_desired_tasks → Desired number of running tasks

Deployment Steps

Initialize Terraform: terraform init

Review the plan: terraform plan

Apply the configuration: terraform apply

Access your application: http://<ALB-DNS>/api/fetch?mobileNumber=4354437687

Architecture Diagram (Text-based)
Internet Users
│
▼
Application Load Balancer (Public Subnet)
│
▼
Target Group → ECS Fargate Tasks (Private Subnet)
│
▼
Spring Boot Container (Port 8080)

Notes:

ALB listens on port 80

Fargate tasks run container on port 8080

Private subnets are not publicly accessible

Summary

Infrastructure is scalable, secure, and repeatable using Terraform

ECS Service runs multiple Fargate tasks for high availability

ALB provides a public endpoint to access the app

Docker image from Docker Hub is deployed

Terraform outputs give key access information for the application
