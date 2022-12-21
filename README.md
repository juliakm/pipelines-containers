# Azure DevOps Docker Containers for Self-Hosted Agents

This repo contains code samples used in [Run a self-hosted agent in Docker](https://learn.microsoft.com/en-us/azure/devops/pipelines/agents/docker?view=azure-devops).

## Ubuntu 20.04 agent

### Prerequisites

* Create a personal access token with read/write permission for Agent Pools
* Create a new agent pool at the organization-level with the name `myAgentPool`

To set up a local self-hosted agent, you'll first build your Docker image and then run the container. When the container is running, you'll install the Azure Pipelines agent.  

1. Go to `ubuntu/dockeragent` and build your container.

    ```code
    docker build -t dockeragent:latest .
    ```

2. Install the latest version of the agent, configures it, and runs the agent. The script targets the `myAgentPool` pool of a specified Azure DevOps or Azure DevOps Server instance of your choice. Replace the `<PAT token>` and`<Azure DevOps instance>` values. Your PAT token needs to have read and write permission for agent pools.

    ```code
    docker run -e AZP_URL=<Azure DevOps instance> -e AZP_TOKEN=<PAT token> -e AZP_POOL=myAgentPool -e AZP_AGENT_NAME=mydockeragent dockeragent:latest
    ```

    If you want a fresh agent container for every pipeline job, pass the `--once` flag to the run command.

3. Go to the **Agent** tab within your Agent Pool and verify that the agent is running.

    ![Screenshot of add agent pool.](media/myagentpool-screenshot.png)

4. Update an existing Azure Pipeline YAML file to use your new agent.

    ```yml
        pool:
          name: myAgentPool   
    ```

5. Run your pipeline and verify that the run completes successfully.