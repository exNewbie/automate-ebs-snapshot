resource "aws_ssm_document" "BackupInstanceEBS" {
  name          = "BackupInstanceEBS"
  document_type = "Automation"

  content = <<DOC
{
  "schemaVersion":"0.3",
  "description":"Create EBS snapshots and remove old snapshots.",
  "assumeRole":"{{AutomationAssumeRole}}",
  "parameters":{
    "instanceIDs":{
      "type":"String",
      "description":"(Required) List of Instance IDs"
    },
    "AutomationAssumeRole":{
      "type":"String",
      "description":"(Required) ARN of Systems Manager Automation Role."
    },
    "SnapshotTimeout":{
      "type":"String",
      "description":"(Required) Timeout for checking for snapshot completion.",
      "default": "PT20M"
    }
  },
  "mainSteps":[
    {
      "name":"createVolumeSnapshots",
      "action":"aws:invokeLambdaFunction",
      "timeoutSeconds":120,
      "maxAttempts":1,
      "onFailure":"Abort",
      "inputs":{
        "FunctionName":"SSM-Automation-CreateSnapshots",
        "Payload":"{\"instanceIDs\":\"{{instanceIDs}}\"}"
      }
    },
    {
      "name":"waitForSnapshotsToCreate",
      "action":"aws:sleep",
      "inputs":{
        "Duration":"{{ SnapshotTimeout }}"
      }
    },
    {
      "name":"checkVolumeSnapshots",
      "action":"aws:invokeLambdaFunction",
      "timeoutSeconds":120,
      "maxAttempts":1,
      "onFailure":"Abort",
      "inputs":{
        "FunctionName":"SSM-Automation-CheckSnapshots",
        "Payload":"{\"snapshotIds\":\"{{createVolumeSnapshots.Payload}}\"}"
      }
    },
    {
      "name":"removeOldSnapshots",
      "action":"aws:invokeLambdaFunction",
      "timeoutSeconds":120,
      "maxAttempts":1,
      "onFailure":"Abort",
      "inputs":{
        "FunctionName":"SSM-Automation-RemoveSnapshotsWithRules",
        "Payload":"{\"instanceIDs\":\"{{instanceIDs}}\"}"
      }
    }
  ]
}
DOC
}
