output "rowvpc-id" {
  value = aws_vpc.vpc.id
}

//to print out public ip
output "ansible_ip" {
  value = aws_instance.ansible.public_ip
}

output "redhat_ip" {
  value = aws_instance.redhat.public_ip
}

output "ubuntu_ip" {
  value = aws_instance.ubuntu.public_ip
}