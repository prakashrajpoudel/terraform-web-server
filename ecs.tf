resource "aws_ecs_cluster" "foo" {
  name = "first-ecs"
}

resource "aws_cloudwatch_log_group" "ecs_services_log_group" {
  name = "/ecs/test"
}