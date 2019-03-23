## TODO

Provision a new application server and deploy the application in this Git repository
------------------------------------------------------------------------------------
- Write configuration-as-code recipes (using your preferred orchestration software) to:
  - Create the server (can be local VM or AWS based)
  - Configure an OS image (your choice) appropriately.
  - Deploy the provided application.
  - Make the application available on port 80.
  - Ensure that the server is locked down and secure.
  
Provide documentation:
----------------------
  - Instructions for the reviewer which explain how your code should be executed
  - Requirements for running. (AWS account? Base images? Other tooling pre-installed?)
  - Explanation of assumptions and design choices.

## Running Application directly on local environment
  - git clone git@github.com:luzhangtina/simple-sinatra-app.git
  - $ `./run-local.sh`
  - Use browser or $ `curl -i 127.0.0.1:8080`

## Building and Running by Using Docker
  - $ `docker build -t simple-sinatra-app .`
  - $ `docker run -p 8080:80 simple-sinatra-app`
  - Use browser or $ `curl -i 127.0.0.1:8080`

## Solution 1: Using Docker + AWS CLI + Fargate

### Installing Dependencies (For Mac)
 - Install Docker 18.09.2(Download and Install https://download.docker.com/)
 - Install AWS CLI  
   $ `brew install awscli`
 - Set AWS Credentials:   
   $ `source <creds-file>`
 
### Create ECR Repository
  - Create and run Cloudformation template
    $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/ecr.yml \
    --stack-name simple-sinatra-app-ecr-repo \
    --capabilities CAPABILITY_IAM \
    --parameters \
        ParameterKey=RepositoryName,ParameterValue='simple-sinatra-app-ecr-repo' \
        ParameterKey=AccountARNs,ParameterValue='arn:aws:iam::047371262158:root'`
        
### Build Image and Push Image to ECR
  - $ `docker build -t simple-sinatra-app .`
  - $ `docker tag simple-sinatra-app:latest 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`
  - $ Set Credentials or Session Keys(aws configure)
  - $ `$(aws ecr get-login --no-include-email --region ap-southeast-2)`
  - $ `docker push 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`

### Create Public VPC
  - $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/public-vpc-two-subnet.yml \
    --stack-name simple-sinatra-app-vpc \
    --capabilities CAPABILITY_IAM `

### Deploy Using Fargate
  - $ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file://<project_path>/cloudformation/fargate.yml \
    --stack-name ssa-on-fargate \
    --capabilities CAPABILITY_IAM `
    
## Solution 2: Using Ansible + Docker + Fargate

### Installing Dependencies for using Python Virtual Env and Ansible
 - Install Docker 18.09.2(Download and Install https://download.docker.com/)
 - Install Python 3.7: https://www.python.org/downloads/release/python-372/
 - Install Virtual Env: `python3.7 -m pip install --user virtualenv`
 - Create Python Virtual Env: `python3.7 -m virtualenv env`
 - Activate Python Virtual Env: `source env/bin/activate`
 - Install Ansible and Dependencies: `pip install ansible boto3 botocore awscli docker-py`
 - Set AWS Credentials: `source <creds-file>`
 - Set AWS account_id in /inventory/development/group_vars/all

### Deploying Application Components on AWS
 - $(aws ecr get-login --no-include-email --region ap-southeast-2)
 - Create ECR, Build Application Container, Upload to ECR:  
   $ ``ansible-playbook build.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``
 - Deploy Application using Fargate: 
   $ ``ansible-playbook deploy.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``
 - (Optional) Using one step operation to build and deploy Application using Fargate: 
   $ ``ansible-playbook build_and_deploy.yml -i inventory/development/ -e "ansible_python_interpreter=`which python`"``

### Price
 - ECR: 
   - Storage is $0.10 per GB-month
   - All data transfer in: $0.00 per GB
   - Data transfer out: Up to 1 GB / Month is $0.00 per GB
 - Fargate: 
   - Monthly Fargate compute charges = monthly CPU charges + monthly memory charges


