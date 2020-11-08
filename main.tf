module "web_key" {
  source                = "git::https://github.com/cloudposse/terraform-aws-key-pair.git?ref=tags/0.4.0"
  namespace             = "sample"
  stage                 = "sampledev"
  name                  = "web"
  ssh_public_key_path   = "./keys"
  generate_ssh_key      = true
  private_key_extension = ""
  public_key_extension  = ".pub"
  chmod_command         = "chmod 600 %v"
}

resource "aws_instance" "web" {
    ami = "${lookup(var.ami, var.aws_region)}"
    instance_type = "t2.micro"
    # VPC
    subnet_id = "${aws_subnet.prod-subnet-public-1.id}"
    # Security Group
    vpc_security_group_ids = ["${aws_security_group.ssh-allowed.id}"]
    # the Public SSH key
    key_name = module.web_key.key_name
   
}
resource "null_resource" "example_provisioner" {
     # nginx installation
    provisioner "file" {
        source = "./nginx.bash"
        destination = "/tmp/nginx.bash"
    }
    provisioner "remote-exec" {
        inline = [
             "chmod +x /tmp/nginx.bash",
             "sudo /tmp/nginx.bash"
        ]
    }
    connection {
        type        = "ssh"
        user        = "ubuntu"
        private_key = file(module.web_key.private_key_filename)
        host        = aws_instance.web.public_dns
    }
    depends_on = [aws_instance.web]
}