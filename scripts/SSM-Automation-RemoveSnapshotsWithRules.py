from __future__ import print_function
from operator import itemgetter

import json
import boto3
import datetime

print('Loading function')
PARAM_BK_RULES='Backup-EBS-Rules'

def del_snapshot(ec2, snapshot):
    print( 'Snapshot ID= %s Snapshot StartTime = %s' % (snapshot['SnapshotId'], snapshot['StartTime'].date()) )
    del_snapshot_response = ec2.delete_snapshot(
        SnapshotId=snapshot['SnapshotId'],
        DryRun=False
    )

#Expects instanceIds
def lambda_handler(event, context):

    print("Received event: " + json.dumps(event, indent=2))
    
    # get EC2 client
    ec2 = boto3.client('ec2')
    ssm = boto3.client('ssm')
    
    retention_rules = ssm.get_parameter( Name=PARAM_BK_RULES, WithDecryption=False )
    retention_rules = json.loads(retention_rules['Parameter']['Value'])

    DAILY_RETENTION = retention_rules['Daily']['Retention']
    YEARLY_RETENTION = retention_rules['Yearly']['Retention']
    MONTHLY_RETENTION = retention_rules['Monthly']['Retention']
    WEEKLY_RETENTION = retention_rules['Weekly']['Retention']
    
    YEARLY_DATE = retention_rules['Yearly']['Day']
    YEARLY_MONTH = retention_rules['Yearly']['Month']
    
    MONTHLY_DATE = retention_rules['Monthly']['Day']
    
    WEEKLY_DATES = retention_rules['Weekly']['Day']
    WEEKLY_DATES = WEEKLY_DATES.split(',')
    
    daily_retention_datetime = datetime.datetime.now() + datetime.timedelta( DAILY_RETENTION )
    yearly_retention_datetime = datetime.datetime.now() + datetime.timedelta( YEARLY_RETENTION )
    monthly_retention_datetime = datetime.datetime.now() + datetime.timedelta( MONTHLY_RETENTION )
    weekly_retention_datetime = datetime.datetime.now() + datetime.timedelta( WEEKLY_RETENTION )
    
    # hold list of DELETED snapshot ids
    snapshotIdList = []

    returnString = ''

    instances = event['instanceIDs'].split(',')
    
    for instance_id in instances:
        # find volumes for given instances
        response = ec2.describe_volumes(
            Filters=[
                {
                    'Name': 'attachment.instance-id',
                    'Values': [ instance_id ],
                },
            ]
        )
    
        # search for snapshots of each volume id
        for ids in response['Volumes']:
            print('List snapshots for volumeId : %s' % ids['VolumeId'])
    
            # create snapshot
            snapshot_response = ec2.describe_snapshots(
                Filters=[
                    {
                        'Name': 'status',
                        'Values': [ 'completed' ]
                    },
                    {
                        'Name': 'volume-id',
                        'Values': [ ids['VolumeId'] ]
                    }
                ],
                DryRun=False
            )

            keyword_exist = False
            for snapshot in snapshot_response['Snapshots']:
                # if a Tag name contains a keyword, this snapshot will be reserved
                if 'Tags' in snapshot:
                    for tag in snapshot['Tags']:
                        if retention_rules['Keyword'] in tag['Value']:
                            keyword_exist = True
                
                if keyword_exist == True:
                    keyword_exist = False
                    continue
                
                # Check retention rules
                # if snapshot is too young, do not delete
                if snapshot['StartTime'].date() > daily_retention_datetime.date():
                    continue
                
                # if created day of snapshot exists on rules, do not delete
                # yearly
                elif snapshot['StartTime'].date().day == YEARLY_DATE and snapshot['StartTime'].date().month == YEARLY_MONTH:
                    if snapshot['StartTime'].date() < yearly_retention_datetime.date():
                        # add snapshot id to be returned
                        snapshotIdList.append(snapshot['SnapshotId'])
                        del_snapshot(ec2, snapshot)
                
                # monthly
                elif snapshot['StartTime'].date().day == MONTHLY_DATE:
                    if snapshot['StartTime'].date() < monthly_retention_datetime.date():
                        # add snapshot id to be returned
                        snapshotIdList.append(snapshot['SnapshotId'])
                        del_snapshot(ec2, snapshot)
                
                # weekly
                elif str(snapshot['StartTime'].date().day) in WEEKLY_DATES:
                    if snapshot['StartTime'].date() < weekly_retention_datetime.date():
                        # add snapshot id to be returned
                        snapshotIdList.append(snapshot['SnapshotId'])
                        del_snapshot(ec2, snapshot)

                else:
                    # add snapshot id to be returned
                    snapshotIdList.append(snapshot['SnapshotId'])
                    del_snapshot(ec2, snapshot)

    returnString = ",".join(str(id) for id in snapshotIdList)
    print("Removed snapshots: %s" % returnString)
    
    return returnString
