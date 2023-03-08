# Prompt for input and then create an Azure Container Instance
#
# Usage
# There are two ways to run the script
# 1. Run it with no parameters
#    cci-full.sh
#    The user is prompted for PAT, org name, and resource group
# 2. Run it with the resource group name as a parameter
#    cci.sh resource-group-name
#    If running this from a learn training module, we can provide the script name
#    with the resource group as a parameter
#    Then the only two prompts are PAT and org name

# set -x #echo on
# Generate a unique integer (date in seconds) to be used for generating unique identifiers
# in the scope of the sandbox
DATE_SEC=$(date +%s)

read -p "Enter Azure DevOps PAT " AZP_TOKEN

# read -p "Enter Agent name (Press enter for MyContainerAgent) " AZP_AGENT_NAME
# echo ${AZP_AGENT_NAME:=MyContainerAgent}
AZP_AGENT_NAME="container_agent_${DATE_SEC}"

# read -p "Enter Agent pool (Press enter for Default) " AZP_POOL
echo ${AZP_POOL:=Default}

read -p "Enter Azure DevOps organization name " AZP_ORG

# Create an Azure Container Registry
if [ -z "$1" ]
then
  # If we didn't get a resource group passed as the first argument, then prompt
  read -p "Enter Azure Resource Group " RESOURCE_GROUP
else
  # Use argument #1
  RESOURCE_GROUP=$1
  echo "Resource group: ${RESOURCE_GROUP}"
fi




# Create an ACR to hold the new image
ACR_NAME="acrlearn${DATE_SEC}"

az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic

ACR_LOCATION=$(az acr show --name $ACR_NAME --output tsv --query [location])
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --output tsv --query [loginServer])
# Create the docker image
curl https://raw.githubusercontent.com/juliakm/pipelines-containers/users/sdanie/acifull/acr/Dockerfile > ./Dockerfile

az acr build --registry $ACR_NAME --image containeragent:v1 .

# Verify the image
az acr repository list --name $ACR_NAME --output table

# Get the credentials to allow deploying an ACI from our image
az acr update -n $ACR_NAME --admin-enabled true

az acr credential show --name $ACR_NAME

ACR_LOGIN=$(az acr credential show --name $ACR_NAME --output tsv --query [username])
ACR_PWD=$(az acr credential show --name $ACR_NAME --output tsv --query [passwords[0].value])

# Verify the image a second time
az acr repository list --name $ACR_NAME --output table

read "press enter"





# read -p "Enter Azure Container Instance name (must be unique in Azure) " ACI_NAME
ACI_NAME="aci-${DATE_SEC}-${RESOURCE_GROUP}"

# read -p "Enter ACI DNS Name " ACI_DNS
ACI_DNS="aci-dns-${DATE_SEC}-${RESOURCE_GROUP}"

echo $DATE_SEC
echo $AZP_AGENT_NAME
echo $ACI_NAME
echo $ACI_DNS
echo $RESOURCE_GROUP

set -x #echo on

# This one uses regular environment variables
# az container create --resource-group ${RESOURCE_GROUP} --name ${ACI_NAME} --image ghcr.io/juliakm/pipelines-containers:main --dns-name-label ${ACI_DNS} --ports 80 --environment-variables "AZP_TOKEN"="$AZP_TOKEN" "AZP_AGENT_NAME"="$AZP_AGENT_NAME" "AZP_POOL"="$AZP_POOL" "AZP_URL"="https://dev.azure.com/$AZP_ORG"

# This one uses secure environment variables for PAT
az container create --resource-group ${RESOURCE_GROUP} --name ${ACI_NAME} --image $ACR_NAME.azurecr.io/containeragent:v1 --dns-name-label ${ACI_DNS} --ports 80 --secure-environment-variables "AZP_TOKEN"="$AZP_TOKEN" --environment-variables "AZP_AGENT_NAME"="$AZP_AGENT_NAME" "AZP_POOL"="$AZP_POOL" "AZP_URL"="https://dev.azure.com/$AZP_ORG" --registry-username $ACR_LOGIN --registry-password $ACR_PWD --registry-login-server $ACR_NAME.azurecr.io --location $ACR_LOCATION

