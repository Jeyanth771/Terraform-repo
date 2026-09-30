variable "region" {
  default = "ap-southeast-2"

}

variable "subnet" {
  type = map(string)
  default = {
    public_subnet  = "10.0.1.0/24"
    private_subnet = "10.0.2.0/24"

  }

}

variable "servers" {
  type = map(string)
  default = {
    bastion = "public_subnet"
    private = "private_subnet"
  }


}

variable "ami" {
  default = "ami-0759dd6cc057c789f"

}

variable "instance_type" {
  default = "t3.micro"

}

variable "key_name" {
  default = "jey_pem"

}