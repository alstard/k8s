aws s3api create-bucket --bucket atd-kops-wulfruntech-uk-state-store --region eu-west-2 --create-bucket-configuration LocationConstraint=eu-west-2


aws s3api put-bucket-versioning --bucket atd-kops-wulfruntech-uk-state-store --versioning-configuration Status=Enabled


kops create cluster --zones eu-west-2b ${NAME}
kops update cluster ${NAME} --yes
kops validate cluster
kops delete cluster --name ${NAME} --yes
kops edit ig --name=kops1.kops.wulfruntech.uk nodes
