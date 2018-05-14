resource "aws_ssm_parameter" "Backup-EBS-Conf" {
  name = "Backup-EBS-Conf"
  type = "String"

  value = <<EOF
{ 
"SnapshotTimeout": [ "${var.timeout}" ],
"instanceIDs": [ "${var.instanceIDs}" ],
"instanceTags": [ "${var.instanceTags}" ],
"AutomationAssumeRole": [ "${aws_iam_role.SystemsManagerAutomation.arn}"]
}
EOF

  overwrite = "true"
}

resource "aws_ssm_parameter" "Backup-EBS-Document" {
  name      = "Backup-EBS-Document"
  type      = "String"
  value     = "BackupInstanceEBS"
  overwrite = "true"
}

resource "aws_ssm_parameter" "Backup-EBS-Rules" {
  name = "Backup-EBS-Rules"
  type = "String"

  value = <<EOF
{
"Keyword": "RESERVED",
"Daily": {
"Day": "",
"Month": "",
"Retention": -7
},
"Yearly": {
"Day": 1,
"Month": 1,
"Retention": -366
},
"Monthly": {
"Day": 1,
"Month": "",
"Retention": -366
},
"Weekly": {
"Day": "1,8,15,22",
"Month": "",
"Retention": -31
}
}
EOF

  overwrite = "true"
}
