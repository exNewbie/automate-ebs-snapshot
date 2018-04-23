resource "aws_lambda_function" "SSM-Automation-CheckSnapshots" {
  function_name    = "SSM-Automation-CheckSnapshots"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-CheckSnapshots.lambda_handler"
  filename         = "${data.archive_file.SSM-Automation-CheckSnapshots.output_path}"
  source_code_hash = "${data.archive_file.SSM-Automation-CheckSnapshots.output_base64sha256}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-CreateSnapshots" {
  function_name    = "SSM-Automation-CreateSnapshots"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-CreateSnapshots.lambda_handler"
  filename         = "${data.archive_file.SSM-Automation-CreateSnapshots.output_path}"
  source_code_hash = "${data.archive_file.SSM-Automation-CreateSnapshots.output_base64sha256}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-RemoveSnapshotsWithRules" {
  function_name    = "SSM-Automation-RemoveSnapshotsWithRules"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-RemoveSnapshotsWithRules.lambda_handler"
  filename         = "${data.archive_file.SSM-Automation-RemoveSnapshotsWithRules.output_path}"
  source_code_hash = "${data.archive_file.SSM-Automation-RemoveSnapshotsWithRules.output_base64sha256}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_function" "SSM-Automation-ExecuteEBSBackup" {
  function_name    = "SSM-Automation-ExecuteEBSBackup"
  role             = "${aws_iam_role.SystemsManagerLambda.arn}"
  handler          = "SSM-Automation-ExecuteEBSBackup.lambda_handler"
  filename         = "${data.archive_file.SSM-Automation-ExecuteEBSBackup.output_path}"
  source_code_hash = "${data.archive_file.SSM-Automation-ExecuteEBSBackup.output_base64sha256}"
  runtime          = "python2.7"
  timeout          = "300"
}

resource "aws_lambda_permission" "SSM-Automation-ExecuteEBSBackup-Schedule" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.SSM-Automation-ExecuteEBSBackup.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.DailyEBSBackup.arn}"
}
