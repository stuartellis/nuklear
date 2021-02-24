# nuklear

Runner for [aws-nuke](https://github.com/rebuy-de/aws-nuke).

## WARNING: VPC Resources

By default, it will destroy default VPC network resources:

https://github.com/rebuy-de/aws-nuke/issues/555

To avoid this, exclude VPC resources from destruction:

- EC2VPC
- EC2Subnet
- EC2InternetGatewayAttachment
- EC2NetworkACL
- EC2RouteTable
- EC2DHCPOption
- EC2InternetGateway

## WARNING: Handling S3 Buckets

By default, aws-nuke checks and logs every individual object in S3 buckets.

To avoid this, nuke only the S3Bucket resources. This will clean up all the objects within the buckets, without logging all of the individual objects.
