import boto3
import json

PARAM_CONF='Backup-EBS-Conf'
PARAM_DOCUMENT='Backup-EBS-Document'

def lambda_handler(event, context):
    # TODO implement
    ssm = boto3.client('ssm')
    
    #PARAM_DOCUMENT = doc_name['Parameter']['Value']
    doc_name = ssm.get_parameter( Name=PARAM_DOCUMENT, WithDecryption=False)
    
    #PARAM_CONF = bk_conf['Parameter']['Value']
    bk_conf = ssm.get_parameter( Name=PARAM_CONF, WithDecryption=False)
    bk_conf = json.loads(bk_conf['Parameter']['Value'])

    #remove empty items
    bk_conf={key: value for key, value in bk_conf.items() if bk_conf[key] and len(value[0]) > 0}

    #start automation
    start_automation = ssm.start_automation_execution(
                                DocumentName=doc_name['Parameter']['Value'],
                                Parameters=bk_conf
                        )
    print(start_automation)
    return start_automation['AutomationExecutionId']
