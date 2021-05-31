# nuklear

Automated AWS account clean-up with [aws-nuke](https://github.com/rebuy-de/aws-nuke) and [Azure DevOps](https://azure.microsoft.com/en-gb/services/devops/).

## IAM Resources

aws-nuke does not support filtering IAM resources types by their tags.

Use *glob* to specify multiple resources that following a naming pattern:

```
IAMGroup:
  - type: glob
    value: "Automated*"
```

## WARNING: VPC Resources

By default, aws-nuke will destroy default VPC network resources:

https://github.com/rebuy-de/aws-nuke/issues/555

To avoid this, exclude VPC resources from destruction:

- EC2VPC
- EC2Subnet
- EC2InternetGatewayAttachment
- EC2NetworkACL
- EC2RouteTable
- EC2DHCPOption
- EC2InternetGateway

## S3

aws-nuke treats data resources as separate from the containing resource. For S3, this means that you must have separate rules for S3 buckets and the objects in the buckets.

The S3 types are:

- S3Bucket
- S3MultipartUpload
- S3Object

For normal use, exclude S3Object. [This issue](https://github.com/rebuy-de/aws-nuke/issues/613) explains that aws-nuke will run slowly and use a lerge amount of resources if required to process thousands of objects in S3 buckets.

Similarly, there are separate types for DynamoDB records and tables:

- DynamoDBTable
- DynamoDBTableItem
