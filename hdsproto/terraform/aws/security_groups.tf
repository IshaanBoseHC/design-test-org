# SECURITY: Define allowed IP ranges for management access
variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the application"
  type        = list(string)
  default = [
    "10.0.0.0/8",      # Internal network
    "172.16.0.0/12",   # Internal network
    "192.168.0.0/16"   # Internal network
  ]
}

# Security group for web application
resource "aws_security_group" "web_app" {
  name        = "${var.project_name}-web-app"
  description = "Security group for web application servers"

  # SECURITY: Keep HTTPS from anywhere (required for public web)
  ingress {
    description = "HTTPS from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # SECURITY: Keep HTTP from anywhere (redirect to HTTPS)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name          = "web-app-sg"
    SecurityLevel = "medium"
  })
}

# SECURITY: Hardened database security group
resource "aws_security_group" "database" {
  name        = "${var.project_name}-database"
  description = "Security group for database servers"

  # SECURITY: Restrict to internal networks only (was 0.0.0.0/0)
  ingress {
    description = "PostgreSQL from internal networks only"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # SECURITY: Restrict egress to only what's needed
  egress {
    description = "HTTPS for updates"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name          = "database-sg"
    SecurityLevel = "high"
  })
}

# SECURITY: New security group for application internal communication
resource "aws_security_group" "app_internal" {
  name        = "${var.project_name}-app-internal"
  description = "Security group for internal app-to-app communication"

  ingress {
    description     = "Allow from web app"
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.web_app.id]
  }

  egress {
    description = "Allow to database"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.database.id]
  }

  tags = merge(var.tags, {
    Name          = "app-internal-sg"
    SecurityLevel = "high"
  })
}
