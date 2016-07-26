INSTANCE-ID=<YOUR EC2 INSTANCE ID>
IDENTITYFILE=/path/to/.ssh/aws-ec2.pem
SSH-USER=ubuntu

start:
	-aws ec2 start-instances --output text --instance-ids $(INSTANCE-ID)

stop:
	-aws ec2 stop-instances --output text --instance-ids $(INSTANCE-ID)

describe:
	aws ec2 describe-instances --output table --instance-ids $(INSTANCE-ID)

wait-start:
	@while :; do STATE=`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"` ; test $$STATE = "running" && exit || echo $$STATE ; sleep 2s; done

ssh: start wait-start
	ssh -i $(IDENTITYFILE) $(SSH-USER)@`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"`

update-ssh-config:
	DNSNAME=`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"` ; sed -i "s/Hostname ec2.*.compute.amazonaws.com\$$/Hostname $$DNSNAME/" $$HOME/.ssh/config


#wait-start:
#	aws ec2 wait instance-status-ok --instance-ids $(INSTANCE-ID)
