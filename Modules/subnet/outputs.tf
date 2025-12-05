output "subnet_ids" {
  description = "List of subnet IDs created by the subnet module"
  value       = [for s in aws_subnet.project_subnet : s.id]
}

output "subnet_CIDR_block" {
  value = [for s in aws_subnet.project_subnet : s.cidr_block]
}

/*
If you need the ids keyed by the original map keys (to preserve meaning like private/public),
use the map form:

output "subnet_ids_map" {
  value = { for k, s in aws_subnet.project_subnet : k => s.id }
}

Then consume `module.subnet.subnet_ids_map["private"]` or similar in the root module.
*/