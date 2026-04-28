# =============================================
#   SSH Key Pair for Web EC2 Instances
# =============================================

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "web_key" {
  key_name   = "${var.project_name}-web-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Save private key locally as .pem file
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/${var.project_name}-web-key.pem"
  file_permission = "0400"
}

output "private_key_path" {
  value       = local_file.private_key.filename
  description = "Path to your SSH private key (.pem file)"
}

output "ssh_command_web1" {
  value       = "ssh -i ${var.project_name}-web-key.pem ec2-user@${aws_instance.web_ec2[0].public_ip}"
  description = "SSH Command for Web Instance 1"
}

output "ssh_command_web2" {
  value       = "ssh -i ${var.project_name}-web-key.pem ec2-user@${aws_instance.web_ec2[1].public_ip}"
  description = "SSH Command for Web Instance 2"
}