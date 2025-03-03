data "aws_lb" "web-lb" {
  tags= {
    Name=var.web-lb-name
  }
}
resource "aws_wafv2_web_acl" "web-acl" {
  name  = "Block suspicious sources"
  scope = "REGIONAL"
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "SuspiciousSources"
    sampled_requests_enabled   = true
  }
  default_action {
    allow {}
  }
  #Blocking sources based on Amazon internal threat intelligene (bots or threat actors)
  rule {
    name     = "AWS-AWSManagedRulesAmazonIpReputationList"
    priority = 0
    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }
  #  Block requests from services that permit the obfuscation of viewer identity (VPNs, proxies & Tor nodes)
  # Filtering out viewers that might be trying to hide their identity from your application.
  # Blocking the IP addresses of these services can help mitigate bots and evasion of geographic restrictions.
  rule {
    name     = "AWSManagedRulesAnonymousIpList"
    priority = 1

    override_action {
      none {
      }
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAnonymousIpList"
        vendor_name = "AWS"

        rule_action_override {
          action_to_use {
            allow {}
          }

          name = "HostingProviderIPList"
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesAnonymousIpList"
      sampled_requests_enabled   = true
    }
  }

}
resource "aws_wafv2_web_acl_association" "web-acl-association" {
  web_acl_arn = aws_wafv2_web_acl.web-acl.arn
  resource_arn = data.aws_lb.web-lb.arn
}