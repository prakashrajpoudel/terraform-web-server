data "aws_caller_identity" "current" {}

resource "aws_iam_role" "ngnix-service" {
  name = "ngnix-service"

  assume_role_policy = <<EOF
{"Version": "2012-10-17","Statement":[{"Sid": "","Effect": "Allow","Principal": {"Service": "ecs-tasks.amazonaws.com"},"Action": "sts:AssumeRole"}]}
EOF
}

// data "aws_iam_policy_document" "ngnix-service" {
//   statement {
//     // actions = [
//     // "secretsmanager:GetSecretValue", ]
//     // resources = []
//   }
// }

// resource "aws_iam_policy" "ngnix-service" {
//   policy = data.aws_iam_policy_document.ngnix-service.json
// }

// resource "aws_iam_role_policy_attachment" "ngnix-service" {
//   role = aws_iam_role.ngnix-service.name
//   policy_arn = aws_iam_policy.ngnix-service.arn
// }

resource "aws_iam_role_policy_attachment" "task-execution" {
  role       = aws_iam_role.ngnix-service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "ecs_tasks" {
  name        = "Ngnix-task"
  vpc_id      = "${aws_vpc.prod-vpc.id}"

  ingress {
    protocol = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecs_task_definition" "ngnix-service" {
  execution_role_arn = aws_iam_role.ngnix-service.arn
  family       = "ngnix-service"
  network_mode = "awsvpc"
  requires_compatibilities = ["FARGATE", ]
  cpu = 512
  memory = 1024
  container_definitions = file("task-definitions/service.json")
}

resource "aws_ecs_service" "ngnix-service" {
  name = "ngnix-service"
  cluster = "${aws_ecs_cluster.foo.id}"
  task_definition = aws_ecs_task_definition.ngnix-service.arn
  launch_type = "FARGATE"
  desired_count = 1

  network_configuration {
    security_groups = [aws_security_group.ecs_tasks.id]
    subnets = ["${aws_subnet.prod-subnet-public-1.id}"]
    assign_public_ip = true
  }
}