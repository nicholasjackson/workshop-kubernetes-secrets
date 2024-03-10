FROM ghcr.io/jumppad-labs/vscode:base-v0.4.0

ARG TARGETARCH

# Install default packages
RUN apt-get update && apt-get upgrade -y && apt-get install -y curl wget zip git jq build-essential postgresql-client

# Clean packages
RUN rm -rf /var/lib/apt/lists/*

# Install Terraform
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/1.7.3/terraform_1.7.3_linux_${TARGETARCH}.zip && \
  unzip terraform.zip && \
  mv terraform /usr/local/bin

# Install Vault
RUN wget -O vault.zip https://releases.hashicorp.com/vault/1.15.6/vault_1.15.6_linux_${TARGETARCH}.zip && \
  unzip vault.zip && \
  mv vault /usr/local/bin

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/${TARGETARCH}/kubectl" && \
  mv ./kubectl /usr/local/bin/kubectl && \
  chmod +x /usr/local/bin/kubectl

# Install VSCode extensions
RUN code-server --install-extension hashicorp.terraform && \
    code-server --install-extension hashicorp.hcl && \
    code-server --install-extension github.github-vscode-theme && \
    code-server --install-extension pkief.material-icon-theme