provider "aws" {
  region = "us-east-1"
}

# Creating the IP Set tp be defined in AWS WAF 
 
resource "aws_waf_ipset" "ipset" {
   name = "deny_all"
   ip_set_descriptors {
     type = "IPV4"
     value = "1.2.3.4/32"
   }
}
 
# Creating the AWS WAF rule that will be applied on AWS Web ACL
 
resource "aws_waf_rule" "waf_rule" { 
  depends_on = [aws_waf_ipset.ipset]
  name        = var.waf_rule_name
  metric_name = var.waf_rule_metrics
  predicates {
    data_id = aws_waf_ipset.ipset.id
    negated = false
    type    = "IPMatch"
  }
}
 
# Creating the Rule Group which will be applied on  AWS Web ACL
 
resource "aws_waf_rule_group" "rule_group" {  
  name        = var.waf_rule_group_name
  metric_name = var.waf_rule_metrics
 
  activated_rule {
    action {
      type = "COUNT"
    }
    priority = 50
    rule_id  = aws_waf_rule.waf_rule.id
  }
}
 
# Creating the Web ACL component in AWS WAF
 
resource "aws_waf_web_acl" "waf_acl" {
  depends_on = [ 
     aws_waf_rule.waf_rule,
     aws_waf_ipset.ipset,
      ]
  name        = var.web_acl_name
  metric_name = var.web_acl_metics
 
  default_action {
    type = "ALLOW"
  }
  rules {
    action {
      type = "BLOCK"
    }
    priority = 1
    rule_id  = aws_waf_rule.waf_rule.id
    type     = "REGULAR"
 }
}