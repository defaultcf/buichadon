resource "aws_elasticache_subnet_group" "main" {
  name       = "${local.project}-main"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
}

resource "aws_security_group" "elasticache" {
  name   = "elasticache"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.app.id]
  }

  tags = {
    Name = "${local.project}-elasticache"
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id         = "${local.project}-main"
  engine             = "redis"
  node_type          = "cache.t3.micro"
  num_cache_nodes    = 1
  engine_version     = "5.0.6"
  port               = 6379
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.elasticache.id]
}
