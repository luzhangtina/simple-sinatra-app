[![Run Status](https://api.shippable.com/projects/5c973d7a5142dd0007ec69ca/badge?branch=master)](https://luzhangtina.github.io/)

## Running Application directly on local environment
  - git clone git@github.com:luzhangtina/simple-sinatra-app.git
  - $ `./run-local.sh`
  - Use browser or $ `curl -i 127.0.0.1:8080`

## Building and Running by Using Docker
  - $ `docker build -t simple-sinatra-app .`
  - $ `docker run -p 8080:80 simple-sinatra-app`
  - Use browser or $ `curl -i 127.0.0.1:8080`
  
## Deployment Design
```
                   +-----------------VPC-----10.0.0.0/21-------------------------------------------+
                   |          +--------Security Group-------------------------------------------+  |
                   |          |                                 +--public subnet one----------+ |  |
                   |          |                                 |  10.0.0.0/23                | |  |
                   |          |                                 | +------Security Group-----+ | |  |
                   |          |                             +---+-+-->ENI<--->Fargate Task  | | |  |
                   |          |                             |   | | public Ip               | | |  |
                   |          |                             |   | | private IP              | | |  |
                   |          |                             |   | +-------------------------+ | |  |
                   |          |                             |   +-----------------------------+ |  |
Internet<--->InternetGateway<-+->Application Load Balancer<-|                                   |  |
                   |          |         public Ip           |   +--public subnet two----------+ |  |
                   |          |                             |   |  10.0.2.0/23                | |  |
                   |          |                             |   | +------Security Group-----+ | |  |
                   |          |                             +---+-+-->ENI<--->Fargate Task  | | |  |
                   |          |                                 | | public Ip               | | |  |
                   |          |                                 | | private Ip              | | |  |
                   |          |                                 | +-------------------------+ | |  |
                   |          |                                 +-----------------------------+ |  |
                   |          +-----------------------------------------------------------------+  |
                   +-------------------------------------------------------------------------------+

```

## Solution 1: Using Docker + AWS CLI + CloudFormation + Fargate

### Installing Dependencies (For Mac)
 - Install Docker 18.09.2(Download and Install https://download.docker.com/)
 - Install AWS CLI  
   $ `brew install awscli`
 - Set AWS Credentials:   
   $ `source <creds-file>`
 
### Creating ECR Repository
  - Create and run Cloudformation template
    $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/ecr.yml \
    --stack-name simple-sinatra-app-ecr-repo \
    --capabilities CAPABILITY_IAM \
    --parameters \
        ParameterKey=RepositoryName,ParameterValue='simple-sinatra-app-ecr-repo' \
        ParameterKey=AccountARNs,ParameterValue='arn:aws:iam::047371262158:root'`
        
### Building Image and Pushing Image to ECR
  - $ `docker build -t simple-sinatra-app .`
  - $ `docker tag simple-sinatra-app:latest 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`
  - $ Set Credentials or Session Keys(aws configure)
  - $ `docker push 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`

### Creating Public VPC
  - $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/vpc_and_two_public_subnets.yml \
    --stack-name simple-sinatra-app-vpc \
    --capabilities CAPABILITY_IAM `

### Deploying by Using Fargate
  - $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/fargate.yml \
    --stack-name ssa-on-fargate \
    --capabilities CAPABILITY_IAM `

### AutoScaling for Fargate
  - $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/ecs_service_autoscaling.yml \
    --stack-name ecs-service-autoscaling \
    --capabilities CAPABILITY_IAM \
    --parameters \
            ParameterKey=FargateStackName,ParameterValue='ssa-on-fargate'`
    
## Solution 2: Using Ansible + Docker + CloudFormation + Fargate

### Installing Dependencies for using Python Virtual Env and Ansible
 - Install Docker 18.09.2(Download and Install https://download.docker.com/)
 - Install Python 3.7: https://www.python.org/downloads/release/python-372/
 - Install Virtual Env: `python3.7 -m pip install --user virtualenv`
 - Create Python Virtual Env: `python3.7 -m virtualenv env`
 - Activate Python Virtual Env: `source env/bin/activate`
 - Install Ansible and Dependencies: `pip install ansible boto3 botocore awscli docker-py`
 - Set AWS Credentials: `source <creds-file>`
 - Set AWS account_id in /inventory/development/group_vars/all

### Deploying Application on AWS
 - Create ECR, Build Application Container, Upload to ECR:  
   $ ``ansible-playbook build.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``
 - Deploy Application using Fargate with autoscaling: 
   $ ``ansible-playbook deploy.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``
 - (Optional) Using one step operation to build and deploy Application using Fargate: 
   $ ``ansible-playbook build_and_deploy.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``
   
### Building CI by Using Shippable 
 - Any merge on github repository will trigger building and deployment on AWS automatically.

### Price
 - ECR: 
   - Storage is $0.10 per GB-month
   - All data transfer in: $0.00 per GB
   - Data transfer out: Up to 1 GB / Month is $0.00 per GB
 - Fargate: 
   - Monthly Fargate compute charges = monthly CPU charges + monthly memory charges


