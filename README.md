**PROJECT 3: Provision and configure the Infra resources using Terraform and Ansible**

**Project Description:**

Provisioning using Terraform and Ansible

**Goals:**

1\. Learning the best practices

2\. Provisioning and configuring the Infra resources

**Technologies Used:**

1\. Terraform

2\. Ansible

**Steps:**

1\. Installation of Terraform

2\. Creating EC2 instances on AWS cloud using Terraform

3\. Configure using Ansible

4\. Writing Terraform scripts

5\. Integration of Terraform and Ansible for configuration management

**Provisioning with Terraform and Ansible**

**Goals:**

- Learn best practices for Infrastructure as Code (IaC) with Terraform.
- Provision EC2 instances on AWS.
- Configure the instances with Ansible playbooks.

**Install Terraform:**

1. **Connect to your EC2 instance:** Use your preferred SSH client to connect to your EC2 instance. You'll need the public IP address and username for this.
2. **Update system packages (if applicable):** This step might vary depending on your Linux distribution on the EC2 instance. Here's an example for Amazon Linux:

~~~
sudo yum update –y
~~~

3. **Install package manager (if needed):** Some Linux distributions might require installing a package manager to add repositories. Here's an example for Amazon Linux if you don't already have it:

~~~
sudo yum install -y yum-utils
~~~

4. **Add HashiCorp repository:** Use the appropriate command based on your Linux distribution to add the official HashiCorp repository for Terraform packages.

Amazon Linux:
~~~
sudo yum-config-manager --add-repo <https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo>
~~~

5. **Update package list:** Refresh the package list to include the newly added HashiCorp repository.
~~~
sudo yum update –y
~~~

6. **Install Terraform:** Finally, install Terraform using the package manager.
~~~
sudo yum install terraform –y
~~~

7. **Verify installation:** Check if Terraform is installed correctly by running the following command:
~~~
terraform –version
~~~

This should display the installed Terraform version.

**Install Ansible:**

The specific command might differ depending on your Linux distribution:

There are two main methods to install Ansible:

**Method A: Using the official package repository (recommended):**

- **Ubuntu/Debian:**
~~~
sudo apt install -y ansible
~~~

- **Amazon Linux:**
~~~
sudo yum install -y ansible
~~~

**Method B: Using pip (package installer for Python):**

This method might require installing Python and python-pip first if they are not already available. Refer to your distribution's documentation for details on installing Python and pip.

Once Python and pip are installed, use the following command:
~~~
sudo pip install ansible
~~~

**Verify installation:** Check if Ansible is installed correctly by running the following command:
~~~
ansible –version
~~~

This should display the installed Ansible version.

**2\. Setting Up AWS Credentials:**

\* We need to tell Terraform how to interact with your AWS account. There are a few ways to do this, but we'll use environment variables for simplicity.

\* Open your terminal and set the following environment variables:
~~~
        export AWS_ACCESS_KEY_ID="your_access_key_id"
        export AWS_SECRET_ACCESS_KEY="your_secret_access_key"
        export AWS_DEFAULT_REGION="ap-south-1"  # Update with your desired region
~~~

\* Replace \`your_access_key_id\` and \`your_secret_access_key\` with your actual credentials from your AWS account (you can find them in the IAM console).

**3\. Terraform Configuration:**

- Create a new directory for your project (e.g., aws-infra).
- Inside this directory, create a file named **main.tf** using a text editor.
- Paste the following code into **main.tf**, replacing placeholders with your details:

Terraform

~~~
# Configure AWS Provider
provider "aws" {
  region = var.aws_region  # Use the variable for region
}

# Define Variables (Optional, but good practice)
variable "aws_region" {
  default = "ap-south-1"
}

# Create a Virtual Private Cloud (VPC)
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Create a public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block         = "10.0.1.0/24"
  availability_zone = " ap-south-1a"  # Update with your desired zone
}

# Create an Internet Gateway
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.my_vpc.id
}

# Attach the internet gateway to the VPC
resource "aws_vpc_endpoint" "internet" {
  vpc_id          = aws_vpc.my_vpc.id
  service_name    = "aws-internet-gateway"
  route_table_ids = [aws_internet_gateway.gateway.route_table_id]
}


# Create a security group allowing SSH access
resource "aws_security_group" "ssh_access" {
  name = "ssh_access"
  description = "Allow SSH access"

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update for specific IP range if desired
  }

  egress {
    from_port = 0
    to_port   = 0
 }
}
~~~


Now go to the command prompt and type
~~~
terraform init
~~~

It installs aws terraform plugins from hashicorp.
~~~
terraform fmt
~~~

Command is used to format your configuration files into a canonical format and style according to the syntax**.**
~~~
terraform validate
~~~

Command validates the syntax.

Now run
~~~
terraform plan
~~~
command for dry run, that is simulation.


After success now finally run the command
~~~
terraform apply
~~~

to create the resources.

**Ansible Playbook and Integration**

Now that you have Terraform set up to provision your infrastructure, let's create an Ansible playbook to configure the EC2 instances.

**4\. Ansible Playbook:**

- Inside your project directory (aws-infra), create another file named playbook.yml using a text editor.
- Paste the following content into playbook.yml:

~~~
---
- name: Configure Web Server
  hosts: all
  become: true  # Allow Ansible to run commands with elevated privileges

  tasks:
    # Update and upgrade packages (replace 'yum' with 'apt' for Ubuntu)
    - name: Update package lists
      yum: update_cache=yes

    - name: Upgrade packages
      yum: upgrade=yes

    # Install a web server (e.g., Apache)
    - name: Install Apache web server
      yum: name=apache2 state=present

    # Ensure service is running
    - name: Start Apache service
      service: name=apache2 state=started enabled=yes

~~~


**Explanation of the Playbook:**

- \---: This line indicates the start of the YAML document.
- \- name: This defines a play named "Configure Web Server".
  - hosts: all: This tells Ansible to run the tasks on all the hosts managed by the playbook (which will be dynamically set up later).
  - become: true: This grants Ansible elevated privileges to perform tasks like installing packages.
- tasks: This defines a list of tasks that Ansible will execute on the target hosts.
  - Each task has a name attribute for better readability.
  - The apt module is used to manage packages on Debian-based systems (like Ubuntu). You might need to replace it with yum for RedHat/CentOS systems.
  - The tasks update package lists, upgrade packages, install the Apache web server, and ensure the service is running and enabled at boot.

**5\. Integration:**

Terraform can provide information about the provisioned resources (like the public IP address of your EC2 instance). We can use this information in our Ansible playbook to dynamically target the created instance.

**Here's how to integrate Terraform and Ansible:**

1. **Run Terraform:** Open your terminal, navigate to your project directory, and run terraform init followed by terraform apply to initialize and apply the Terraform configuration. This will create the infrastructure resources on AWS.
2. **Inventory File (Optional):** While hosts: all works for a single instance, for multiple instances, create a file named inventory in your project directory. Add the public IP address of your EC2 instance retrieved from Terraform output (you can use terraform output public_ip to view the output).
~~~
[webservers]
your_public_ip_address
~~~

1. **Ansible Playbook Update:** Modify the hosts section in your playbook.yml to use the inventory file:

YAML
~~~
- name: Configure Web Server
  hosts: webservers  # Use the inventory file name
  become: true
  # ... rest of the playbook tasks ...
~~~


1. **Run Ansible Playbook:** With Terraform resources provisioned and the inventory file set up, navigate to your project directory and run
~~~
ansible-playbook playbook.yml
~~~
to execute the Ansible playbook and configure your web server on the EC2 instance.
