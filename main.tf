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

resource "aws_elasticache_cluster" "elasticache" {
  cluster_id         = "${var.env}-elasticache-cluster"
  engine             = "redis"
  node_type          = var.node_type
  num_cache_nodes    = var.num_cache_nodes
  engine_version     = var.engine_version
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.default.name
  security_group_ids = [aws_security_group.elasticache.id]
  tags = merge(
    local.common_tags,
    { Name = "${var.env}-elasticache" }
  )
}

resource "aws_ssm_parameter" "elasticache_endpoint" {
  name  = "${var.env}.elasticache.ENDPOINT"
  type  = "String"
  value = aws_elasticache_cluster.elasticache.cache_nodes[0].address
}

