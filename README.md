###TODO:

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


### To Run Locally
git clone git@github.com:luzhangtina/simple-sinatra-app.git
$ `./run-local.sh`
Use browser or $ `curl -i 127.0.0.1:8080`

### To Build and Run Using Docker
Install Docker 18.09.2
$ `docker build -t simple-sinatra-app .`
$ `docker run -p 8080:9292 simple-sinatra-app`
Use browser or $ `curl -i 127.0.0.1:8080`

### Solution 1: Using Docker + Fargate

#### Create ECR Repo
Install AWS CLI (for mac brew install awscli)
Create and Run Cloudformation Template
$ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file:///Users/tina/Projects/REAHomeWork/simple-sinatra-app/deploy/ecr.yml \
    --stack-name simple-sinatra-app-ecr-repo \
    --capabilities CAPABILITY_IAM \
    --parameters \
        ParameterKey=RepositoryName,ParameterValue='simple-sinatra-app-ecr-repo' \
        ParameterKey=AccountARNs,ParameterValue='arn:aws:iam::047371262158:root'`
        

#### Build Image and Push Image to ECR
$ `docker build -t simple-sinatra-app .`
$ `docker tag simple-sinatra-app:latest 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`
$ Set Credentials or Session Keys(aws configure)
$ `$(aws ecr get-login --no-include-email --region ap-southeast-2)`
$ `docker push 047371262158.dkr.ecr.ap-southeast-2.amazonaws.com/simple-sinatra-app-ecr-repo:latest`

#### Create Public VPC
$ `aws cloudformation create-stack   \
    --region ap-southeast-2    \
    --template-body file:///Users/tina/Projects/REAHomeWork/simple-sinatra-app/deploy/public-vpc.yml    \
    --stack-name public-vpc     \
    --capabilities CAPABILITY_IAM `

#### Deploy Using Fargate
$ `aws cloudformation create-stack \
    --region ap-southeast-2 \
    --template-body file:///Users/tina/Projects/REAHomeWork/simple-sinatra-app/deploy/public-subnet-public-loadbalancer.yml \
    --stack-name simple-sinatra-app-on-fargate \
    --capabilities CAPABILITY_IAM `

### Solution 2: Using traditional AMI + EC2  based deployment


### Solution 1: Elastic Beanstalk - Cloudformation

