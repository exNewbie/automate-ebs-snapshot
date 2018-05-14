# automate-ebs-snapshot
Using CloudWatch to trigger Lambda functions which create snapshots belonging to instances
https://blog.funnyto.be/node/2

```python
module "ebs_snapshot" {
  source = "git::ssh://git@bitbucket.org/minergroup/tf-modules.git//providers/aws/ebs-snapshot?ref=feature/DEVOPS-248"

  providers = {
    "aws" = "aws.default"
  }

  # Module variables
  region       = "ap-southeast-2"
  instanceIDs  = "${var.instanceIDs}"
  instanceTags = "${var.instanceTags}"
  timeout      = "${var.timeout}"
}
```

```python
variable "instanceIDs" {
  type        = "string"
  description = "List of instance IDs separated by comma that their EBS volumes will be backed up"
}

variable "timeout" {
  type        = "string"
  description = "Time to wait for all snapshot creation to finish"
}

variable "instanceTags" {
  type        = "string"
  description = "List of tag names and values in JSON that their EBS volumes will be backed up"
}
```
