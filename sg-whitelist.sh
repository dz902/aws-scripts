#!/bin/bash
trap "exit" INT

export PS4='#${LINENO}: '
set -x

GROUP_ID="${1:-sg-xxx}"
PORT="${2:-22}"
AWS_PAGER="" aws ec2 describe-security-groups --group-id $GROUP_ID --query SecurityGroups[].IpPermissions[] | jq -c '.[]' | 
while read -r -a ip_permissions
    do 
    for ip in ${ip_permissions[@]}
    do
        echo "${ip}"
        AWS_PAGER="" aws ec2 revoke-security-group-ingress --group-id $GROUP_ID --ip-permissions "${ip}"
    done
done
AWS_PAGER="" aws ec2 authorize-security-group-ingress --group-id $GROUP_ID --cidr $(curl -s https://checkip.amazonaws.com)/32 --protocol tcp --port $PORT
