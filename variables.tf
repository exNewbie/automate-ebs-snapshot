variable region {
  default     = "ap-southeast-2"
  description = "The AWS region where we want create the resources"
}

variable instanceIDs {
  default     = ""                     # "i-018a3e781d,i-0a7a324722d,i-0f8d8566"
  description = "List of instance IDs"
}

provider "aws" {
  region  = "${var.region}"
  profile = "default"
}
