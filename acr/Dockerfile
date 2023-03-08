FROM mcr.microsoft.com/dotnet/sdk:6.0-focal-amd64 as dotnet
RUN DEBIAN_FRONTEND=noninteractive apt-get update
RUN DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    apt-transport-https \
    apt-utils \
    ca-certificates \
    curl \
    git \
    iputils-ping \
    jq \
    lsb-release \
    software-properties-common \
    # .NET dependencies
    libc6 \
    libgcc1 \
    libgssapi-krb5-2 \
    libicu66 \
    libssl1.1 \
    libstdc++6 \
    zlib1g \
    && rm -rf /var/lib/apt/lists/*


# Install NodeJS
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt-get -qqy --no-install-recommends install nodejs

# Create user "node"
RUN groupadd --gid 1000 node \
    && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

RUN npm install --global gulp-cli

RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Can be 'linux-x64', 'linux-arm64', 'linux-arm', 'rhel.6-x64'.
ENV TARGETARCH=linux-x64

WORKDIR /azp

ADD https://raw.githubusercontent.com/juliakm/pipelines-containers/main/ubuntu/dockeragent/start.sh ./start.sh
RUN chmod +x start.sh

ENTRYPOINT [ "./start.sh" ]