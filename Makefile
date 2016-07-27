INSTANCE-ID=<YOUR EC2 INSTANCE ID>
IDENTITYFILE=/path/to/.ssh/aws-ec2.pem
SSH-USER=ubuntu
OPEN=cygstart
port=10080
porotocol=http

# show infomation of the instance
describe:
	@aws ec2 describe-instances --output table --instance-ids $(INSTANCE-ID)

# start the instance
start:
	-aws ec2 start-instances --output text --instance-ids $(INSTANCE-ID)

# stop the instance
stop:
	-aws ec2 stop-instances --output text --instance-ids $(INSTANCE-ID)

# wait and print current status until the instance running
wait-start:
	@while :; do STATE=`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].State.Name"` ; test $$STATE = "running" && exit || echo $$STATE ; sleep 2s; done

#wait-start:
#	aws ec2 wait instance-status-ok --instance-ids $(INSTANCE-ID)

# ssh connection
ssh: start wait-start
	ssh -i $(IDENTITYFILE) $(SSH-USER)@`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"`

# update .ssh/config for ssh, scp, etc.
update-ssh-config:
	DNSNAME=`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"` ; sed -i "s/Hostname ec2.*.compute.amazonaws.com\$$/Hostname $$DNSNAME/" $$HOME/.ssh/config

# show Public DNS name
name:
	@aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"

# open web site in local browser
open:
	$(OPEN) $(protocol)://`aws ec2 describe-instances --output text --instance-ids $(INSTANCE-ID) --query "Reservations[0].Instances[0].PublicDnsName"`:$(port)
