import boto3
import datetime

ec = boto3.client('ec2')

# Set the default retention days
retention_days = 3

# Get the instances that has the tag with value backup
reservations = ec.describe_instances(
        Filters=[
            {'Name': 'tag-value', 'Values': ['backup']},
        ]
    )['Reservations']

# We are only interested in the instance data.
instances = sum(
    [
        [i for i in r['Instances']]
        for r in reservations
    ], [])

for instance in instances:
    for dev in instance['BlockDeviceMappings']:
        if dev.get('Ebs', None) is None:
            # skip non-EBS volumes
            continue
        vol_id = dev['Ebs']['VolumeId']
        print "Found EBS volume %s on instance %s" % (
            vol_id, instance['InstanceId'])
        # Create the backup
        snap = ec.create_snapshot(
            VolumeId=vol_id,
        )
        # get the date X days in the future
        delete_date = datetime.date.today() + datetime.timedelta(days=retention_days)
        delete_fmt = delete_date.strftime('%Y-%m-%d')
        # Set the delete on tag on the snapshot.
        ec.create_tags(
        	Resources=[snap['SnapshotId']],
        	Tags=[
            	{'Key': 'DeleteOn', 'Value': delete_fmt},
        	]
    	)

# Check for instances that should be deleted today

delete_on = datetime.date.today().strftime('%Y-%m-%d')
filters = [
    {'Name': 'tag-key', 'Values': ['DeleteOn']},
    {'Name': 'tag-value', 'Values': [delete_on]},
]
# The owner id can be found on the bill for you aws account.
owner_ids = []
if not owner_ids:
	return

snapshot_response = ec.describe_snapshots(Filters=filters, OwnerIds=owner_ids)

for snap in snapshot_response['Snapshots']:
    print "Deleting snapshot %s" % snap['SnapshotId']
    ec.delete_snapshot(SnapshotId=snap['SnapshotId'])
