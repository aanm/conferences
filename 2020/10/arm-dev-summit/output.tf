output "public-ip" {
  value = join(",", aws_instance.arm-dev-workshop.*.public_ip)
}
