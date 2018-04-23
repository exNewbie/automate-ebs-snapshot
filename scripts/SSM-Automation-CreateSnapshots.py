from __future__ import print_function

import json
import boto3

print('Loading function')

#Expects instanceIds
def lambda_handler(event, context):
    
    print("Received event: " + json.dumps(event, indent=2))

    # get EC2 client
    ec2 = boto3.client('ec2')

    instances = event['instanceIDs'].split(',')
    
    for instance_id in instances:
        # find tags
        list_tags_response = ec2.describe_tags(
                                Filters=[
                                    {
                                        'Name': 'resource-id',
                                        'Values': [ instance_id ]
                                    }
                                ]
        )
    
        for tag in list_tags_response['Tags']:
            if tag['Key'] == 'Name':
                name_tag = tag['Value']
    
    
        # find volumes for given instances
        response = ec2.describe_volumes(
            Filters=[
                {
                    'Name': 'attachment.instance-id',
                    'Values': [ instance_id ],
                },
            ]
        )
    
        # hold list of snapshot ids
        snapshotIdList = []
        
        # create snapshot of each volume id
        for ids in response['Volumes']:
            print('Creating snapshot for volumeId : %s' % ids['VolumeId'])
            
            # create snapshot
            response = ec2.create_snapshot(
                Description='Snapshot created by Lambda function',
                VolumeId=ids['VolumeId'],
                DryRun=False
            )
            
            print('Created snapshotId : %s' % response['SnapshotId'])
    
            # add Name tag to snapshot
            add_response = ec2.create_tags(
                Resources=[
                    response['SnapshotId']
                ],
                Tags=[
                    {
                        'Key': 'Name',
                        'Value': name_tag
                    }
                ]
            )
    
            # add snapshot id to be returned
            snapshotIdList.append(response['SnapshotId'])
        
        returnString = ",".join(str(id) for id in snapshotIdList)

    return returnString
