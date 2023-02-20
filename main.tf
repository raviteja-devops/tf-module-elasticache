resource "aws_elasticache_subnet_group" "default" {
  name       = "${var.env}-elasticache-subnet-group"
  subnet_ids = var.subnet_ids
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-elasticache-subnet-group" }
  )
}


resource "aws_security_group" "elasticache" {
  name        = "${var.env}-elasticache-security-group"
  description = "${var.env}-elasticache-security-group"
  vpc_id      = var.vpc_id
  ingress {
    description      = "elasticache"
    from_port        = 6379
    to_port          = 6379
    protocol         = "tcp"
    cidr_blocks      = var.allow_cidr
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-elasticache-security-group" }
  )
}

resource "aws_elasticache_replication_group" "elasticache" {
  replication_group_id       = "${var.env}-elasticache"
  description                = "${var.env}-elasticache"
  node_type                  = var.node_type
  port                       = 6379
  automatic_failover_enabled = true
  subnet_group_name = aws_elasticache_subnet_group.default.name
  security_group_ids = [aws_security_group.elasticache.id]
  num_node_groups = var.num_node_groups
  replicas_per_node_group = var.replicas_per_node_group
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-elasticache" }
  )
}