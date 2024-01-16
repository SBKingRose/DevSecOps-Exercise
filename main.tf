provider "aws" {
  region = "us-east-1"
}

module "eks" {
  source              = "terraform-aws-modules/eks/aws"
  cluster_name        = "supermarket-checkout-cluster"
  subnets             = ["subnet-abc", "subnet-ghi", "subnet-def"]
  vpc_id              = "vpc-xyz"
  node_groups         = {
    eks_nodes = {
      desired_capacity = 2
      max_capacity     = 3
      min_capacity     = 1
    }
  }
}

resource "kubernetes_deployment" "supermarket_checkout_app" {
  metadata {
    name = "supermarket-checkout"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "supermarket-checkout"
      }
    }

    template {
      metadata {
        labels = {
          app = "supermarket-checkout"
        }
      }

      spec {
        container {
          image = "<your-aws-account-id>.dkr.ecr.<your-region>.amazonaws.com/supermarket-checkout:latest"
          name  = "supermarket-checkout"

          port {
            container_port = 8080
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "supermarket_checkout_service" {
  metadata {
    name = "supermarket-checkout-service"
  }

  spec {
    selector = {
      app = "supermarket-checkout"
    }

    port {
      port        = 80
      target_port = 8080
    }
  }
}

resource "aws_cloudfront_distribution" "supermarket_checkout_cdn" {
  origin {
    domain_name = module.eks.cluster_endpoint
    origin_id   = "eks-cluster-origin"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"


}
