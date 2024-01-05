import os
import boto3

def lambda_handler(event, context):
    ecs = boto3.client('ecs')

    # Get the cluster and service names from environment variables
    cluster_name = os.getenv('CLUSTER_NAME')
    service_name = os.getenv('SERVICE_NAME')

    if event['time'] == '18:00:00':
        # Update the service to set the desired count to 0
        ecs.update_service(cluster=cluster_name, service=service_name, desiredCount=0)
        print('Stopped service: ' + service_name)
    elif event['time'] == '07:00:00':
        # Update the service to set the desired count to 1
        ecs.update_service(cluster=cluster_name, service=service_name, desiredCount=1)
        print('Started service: ' + service_name)