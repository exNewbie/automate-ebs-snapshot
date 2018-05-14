resource "aws_cloudwatch_event_rule" "DailyEBSBackup" {
  name                = "DailyEBSBackup-${random_pet.name-suffix.id}"
  schedule_expression = "cron(55 11 * * ? *)"
}

resource "aws_cloudwatch_event_target" "DailyEBSBackup-Target" {
  rule = "${aws_cloudwatch_event_rule.DailyEBSBackup.name}"
  arn  = "${aws_lambda_function.SSM-Automation-ExecuteEBSBackup.arn}"
}
