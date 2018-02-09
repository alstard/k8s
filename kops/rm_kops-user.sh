#!/bin/bash
#set -ex

KOPS_USER=$1
KOPS_GROUP=$2

usage(){
	echo "Usage: $0 KOPS_USER KOPS_GROUP"
	exit 1
}

# Check 2 command line arguments given
[[ $# -ne 2 ]] && usage

echo
echo "DELETING AWS IAM Objects - Kops User:   $KOPS_USER"
echo "DELETING AWS IAM Objects - Kops Group:  $KOPS_GROUP"
echo
read -p "PRESS [ENTER] TO CONTINUE..."
echo

# 1. Remove User from Group
aws iam remove-user-from-group --user-name $KOPS_USER --group-name $KOPS_GROUP

# 2. List & Remove policies from Group
for i in `aws iam list-attached-group-policies --group-name $KOPS_GROUP | jq -r '.AttachedPolicies | .[] | .PolicyArn'`
do
  aws iam detach-group-policy --group-name $KOPS_GROUP --policy-arn $i
done


# 3. Delete Group
aws iam delete-group --group-name $KOPS_GROUP

# 4. Delete User (but delete access keys and login profile first)
aws iam delete-access-key --user-name $KOPS_USER --access-key-id $(aws iam list-access-keys --user-name $KOPS_USER | jq -r '.AccessKeyMetadata | .[] | .AccessKeyId')
aws iam delete-user --user-name $KOPS_USER