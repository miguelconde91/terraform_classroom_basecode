##############
#   Output   #
##############

output "s3-policy" {
  value = aws_iam_policy.lambda_s3-generic-integration-test.arn
}