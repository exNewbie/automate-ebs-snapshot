/* SystemsManagerAutomation Role */
resource "aws_iam_role" "SystemsManagerAutomation" {
  name = "SystemsManagerAutomation"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "ssm.amazonaws.com",
          "ec2.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "SystemsManagerAutomation-Attach-AmazonEC2RoleforSSM" {
    role       = "${aws_iam_role.SystemsManagerAutomation.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

resource "aws_iam_role_policy_attachment" "SystemsManagerAutomation-Attach-AmazonSSMAutomationRole" {
    role       = "${aws_iam_role.SystemsManagerAutomation.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonSSMAutomationRole"
}

resource "aws_iam_role_policy_attachment" "SystemsManagerAutomation-Attach-AWSLambdaRole" {
    role       = "${aws_iam_role.SystemsManagerAutomation.name}"
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaRole"
}

/* ################################################################################################### */
/* SystemsManagerLambda Role */

resource "aws_iam_role" "SystemsManagerLambda" {
  name = "SystemsManagerLambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "SystemsManagerLambda-Attach-AmazonEC2FullAccess" {
    role       = "${aws_iam_role.SystemsManagerLambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_role_policy_attachment" "SystemsManagerLambda-Attach-AmazonSSMFullAccess" {
    role       = "${aws_iam_role.SystemsManagerLambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}

resource "aws_iam_role_policy_attachment" "SystemsManagerLambda-Attach-AWSLambdaExecute" {
    role       = "${aws_iam_role.SystemsManagerLambda.name}"
    policy_arn = "arn:aws:iam::aws:policy/AWSLambdaExecute"
}

resource "aws_iam_role_policy" "PassAutomationRole" {
    name = "PassAutomationRole"
    role = "${aws_iam_role.SystemsManagerLambda.id}"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "${aws_iam_role.SystemsManagerAutomation.arn}"
        }
    ]
}
EOF
}
