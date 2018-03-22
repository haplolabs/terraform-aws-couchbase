#!/bin/bash

set -e

# Send the log output from this script to user-data.log, syslog, and the console
# From: https://alestic.com/2010/12/ec2-user-data-output/
exec > >(tee /opt/couchbase/var/lib/couchbase/logs/mock-user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# The variables below come from mock-couchbase.env or entrypoint.env

# Start Couchbase. Note that we use the --create-bucket-for-testing flag to create a bucket we can use for testing with
# Sync Gateway. In normal production usage, you should NOT copy that setting.
/opt/couchbase/bin/run-couchbase-server \
  --cluster-name "${cluster_asg_name}" \
  --cluster-username "${cluster_username}" \
  --cluster-password "${cluster_password}" \
  --rally-point-port "${cluster_port}" \
  --rest-port "${cluster_port}" \
  --create-bucket-for-testing "${default_bucket_name}"

# Start Sync Gateway
/opt/couchbase-sync-gateway/bin/run-sync-gateway \
  --auto-fill-asg "<SERVERS>=${cluster_asg_name}:${cluster_port}" \
  --auto-fill "<BUCKET_NAME>=${default_bucket_name}" \
  --auto-fill "<INTERFACE>=${sync_gateway_interface}" \
  --auto-fill "<ADMIN_INTERFACE>=${sync_gateway_admin_interface}" \
  --auto-fill "<DB_NAME>=${cluster_asg_name}" \
  --auto-fill "<DB_USERNAME>=${cluster_username}" \
  --auto-fill "<DB_PASSWORD>=${cluster_password}"
