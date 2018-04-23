from __future__ import print_function

import json
import boto3

print('Loading function')

#Expects snapshotIds
def lambda_handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))
    
    # get EC2 client
    ec2 = boto3.client('ec2')
    
    # get the snapshotIds passed
    snapshotIds = event['snapshotIds'].split(',')
    
    # check the state of each snapshot
    for id in snapshotIds:
        response = ec2.describe_snapshots(
            SnapshotIds=[
                id,
            ],
            DryRun=False
        )
        
        # if the state is not completed then it can't continue, so throw an error
        for state in response['Snapshots']:
            print('SnapshotId ' + id + ' in state : %s' % state['State'])
            
            if state['State'] != 'completed':
                errorString = 'Unable to proceed, snapshot in ' + state['State'] + ' state for: ' + id
                raise Exception(errorString)
    
    return "Snapshots completed."
