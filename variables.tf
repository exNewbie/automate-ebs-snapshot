### Variables ###

variable region {
  default     = "ap-southeast-2"
  description = "The AWS region where we want create the resources"
}

variable instanceIDs {
  default     = ""                     # "i-018a3e781d,i-0a7a324722d,i-0f8d8566"
  description = "List of instance IDs"
}

variable timeout {
  description = "Wait for snapshot creation to complete"
  default     = "PT60M"
}

variable instanceTags {
  default     = ""                     # "[ { "Name": "tag:Role", "Values": [ "app-staging" ] } ]"
  description = "Tag names and values"
}

### Data ###

data "archive_file" "SSM-Automation-CheckSnapshots" {
  type        = "zip"
  source_file = "${path.module}/scripts/SSM-Automation-CheckSnapshots.py"
  output_path = "${path.module}/scripts/SSM-Automation-CheckSnapshots.zip"
}

data "archive_file" "SSM-Automation-CreateSnapshots" {
  type        = "zip"
  source_file = "${path.module}/scripts/SSM-Automation-CreateSnapshots.py"
  output_path = "${path.module}/scripts/SSM-Automation-CreateSnapshots.zip"
}

data "archive_file" "SSM-Automation-ExecuteEBSBackup" {
  type        = "zip"
  source_file = "${path.module}/scripts/SSM-Automation-ExecuteEBSBackup.py"
  output_path = "${path.module}/scripts/SSM-Automation-ExecuteEBSBackup.zip"
}

data "archive_file" "SSM-Automation-RemoveSnapshotsWithRules" {
  type        = "zip"
  source_file = "${path.module}/scripts/SSM-Automation-RemoveSnapshotsWithRules.py"
  output_path = "${path.module}/scripts/SSM-Automation-RemoveSnapshotsWithRules.zip"
}

### Resources ###

resource "random_pet" "name-suffix" {
  length = 1
}
