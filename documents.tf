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
      "description":"(Required) List of Instance IDs",
      "default": ""
    },
    "instanceTags":{
      "type":"String",
      "description":"(Required) Tag names and values",
      "default": ""
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
        "FunctionName":"SSM-Automation-CreateSnapshots-${random_pet.name-suffix.id}",
        "Payload":"{\"instanceIDs\":\"{{instanceIDs}}\", \"instanceTags\":\"{{instanceTags}}\"}"
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
        "FunctionName":"SSM-Automation-CheckSnapshots-${random_pet.name-suffix.id}",
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
        "FunctionName":"SSM-Automation-RemoveSnapshotsWithRules-${random_pet.name-suffix.id}",
        "Payload":"{\"instanceIDs\":\"{{instanceIDs}}\", \"instanceTags\":\"{{instanceTags}}\"}"
      }
    }
  ]
}
DOC
}
