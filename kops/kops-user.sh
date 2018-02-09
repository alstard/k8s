#!/bin/bash
set -ex

KOPS_USER=$1
KOPS_GROUP=$2
KOPS_CREDS=/tmp/aws-kops-creds.$$

usage(){
	echo "Usage: $0 KOPS_USER KOPS_GROUP"
	exit 1
}

# Check 2 command line arguments given
[[ $# -ne 2 ]] && usage

echo
echo "Creating AWS IAM Objects - Kops User:   $KOPS_USER"
echo "Creating AWS IAM Objects - Kops Group:  $KOPS_GROUP"
echo

aws iam create-group --group-name $KOPS_GROUP

aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonEC2FullAccess --group-name $KOPS_GROUP
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonRoute53FullAccess --group-name $KOPS_GROUP
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --group-name $KOPS_GROUP
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/IAMFullAccess --group-name $KOPS_GROUP
aws iam attach-group-policy --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess --group-name $KOPS_GROUP

aws iam create-user --user-name $KOPS_USER

aws iam add-user-to-group --user-name $KOPS_USER --group-name $KOPS_GROUP

aws iam create-access-key --user-name $KOPS_USER --output json > $KOPS_CREDS

KOPS_ACCESS_KEY_ID=`cat $KOPS_CREDS | jq -r '.AccessKey | .AccessKeyId'`
KOPS_SECRET_KEY_ID=`cat $KOPS_CREDS | jq -r '.AccessKey | .SecretAccessKey'`
rm -f $KOPS_CREDS

echo
echo "SUCCESS:      Created User and access keys"
echo "AccessKeyID:  $KOPS_ACCESS_KEY_ID"
echo "SecretKeyID:  $KOPS_SECRET_KEY_ID"
echo




# 1. Remove User from Group
# 2. List & Remove policies from Group
# 3. Delete Group
# 4. Delete User (but delete access keys and login profile first)


# 1.  aws iam remove-user-from-group --user-name $KOPS_USER --group-name $KOPS_GROUP

# 2.  for i in `aws iam list-attached-group-policies --group-name atd-testgroup1 | jq -r '.AttachedPolicies | .[] | .PolicyArn'`
#     do
#       aws iam detach-group-policy --group-name atd-testgroup1 --policy-arn $i
#     done

# 3.  aws iam delete-group --group-name $KOPS_GROUP

# 4.  aws iam delete-access-key --user-name $KOPS_USER --access-key-id $(aws iam list-access-keys --user-name $KOPS_USER | jq -r '.AccessKeyMetadata | .[] | .AccessKeyId')
#     aws iam delete-user --user-name $KOPS_USER