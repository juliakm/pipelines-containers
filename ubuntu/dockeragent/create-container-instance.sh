# Prompt for input and then create an Azure COntainer Instance
# read -p "What is your name? " my_var 

# AZP_TOKEN
# AZP_AGENT_NAME
# AZP_POOL
# AZP_URL
# RESOURCE_GROUP

read -p "Enter Azure DevOps PAT " AZP_TOKEN

read -p "Enter Agent name (Press enter for MyContainerAgent) " AZP_AGENT_NAME
echo ${AZP_AGENT_NAME:=MyContainerAgent}

read -p "Enter Agent pool (Press enter for Default) " AZP_POOL
echo ${AZP_POOL:=Default}

read -p "Enter Azure DevOps organization name " AZP_ORG

read -p "Enter Azure Resource Group " RESOURCE_GROUP

read -p "Enter Azure Container Instance name (must be unique in Azure) " ACI_NAME

# echo "az ${AZP_TOKEN}"

read -p "Enter ACI DNS Name " ACI_DNS

# echo "az container create --resource-group ${RESOURCE_GROUP} --name ${ACI_NAME} --image ghcr.io/juliakm/pipelines-containers:main --dns-name-label aci-acr-demo --ports 80 --environment-variables 'AZP_TOKEN'='${AZP_TOKEN}' 'AZP_AGENT_NAME'='${AZP_AGENT_NAME}' 'AZP_POOL'='${AZP_POOL}' 'AZP_URL'='https://dev.azure.com/${AZP_ORG}'"

az container create --resource-group ${RESOURCE_GROUP} --name ${ACI_NAME} --image ghcr.io/juliakm/pipelines-containers:main --dns-name-label ${ACI_DNS} --ports 80 --environment-variables 'AZP_TOKEN'='$AZP_TOKEN' 'AZP_AGENT_NAME'='$AZP_AGENT_NAME' 'AZP_POOL'='$AZP_POOL' 'AZP_URL'='https://dev.azure.com/$AZP_ORG'