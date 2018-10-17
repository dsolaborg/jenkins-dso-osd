output "aws_lb" {
  description = "The DNS name of the ELB"
  value       = "${aws_lb.front_end.dns_name}"
}

output "dns_name" {
  description = "The DNS Name"
  value       = "${aws_route53_record.www.fqdn}"
}
