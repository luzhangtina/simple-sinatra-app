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
git clone git@github.com:rea-cruitment/simple-sinatra-app.git
shell $ bundle install
shell $ bundle exec rackup -o 0.0.0.0  -p 8080 

### To Build and Run Using Docker
Install Docker 18.09.2
$ `docker build -t simple-sinatra-app .`
$ `docker run -p 80:9291 simple-sinatra-app`

### Solution 1: Using traditional AMI + EC2  based deployment

### Solution 2: Using Docker + Fargate

### Solution 1: Elastic Beanstalk - Cloudformation

