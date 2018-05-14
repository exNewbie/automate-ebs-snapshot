from __future__ import print_function

import json
import boto3
import ast

print('Loading function')

def get_instance_ids(event, ec2):  
    response_instances = ec2.describe_instances(
        Filters=ast.literal_eval(event['instanceTags'])
    )
    
    instanceIdList = []  
    for instance in response_instances['Reservations'][0]['Instances']:
        instanceIdList.append(instance['InstanceId'])
    
    returnString = ",".join(str(id) for id in instanceIdList)
    return returnString

#Expects instanceIds
def lambda_handler(event, context):
    
    print("Received event: " + json.dumps(event, indent=2))

    #remove empty items
    event={key: value for key, value in event.items() if event[key] and len(value[0]) > 0}

    # get EC2 client
    ec2 = boto3.client('ec2')

    if 'instanceTags' in event:
        instances = get_instance_ids(event, ec2).split(',')
    else:
        print('No tags')
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
