# Setup build arguments with default versions
ARG AWS_CLI_VERSION=1.22.26
ARG TERRAFORM_VERSION=1.1.2
ARG PYTHON_MAJOR_VERSION=3.9
ARG DEBIAN_VERSION=bullseye-20210902-slim
ARG DOCKER_VERSION=20.10.10
ARG AWS_NUKE_VERSION=2.17.0

# Download Docker binary
FROM debian:${DEBIAN_VERSION} as docker
ARG DOCKER_VERSION
RUN apt-get update
RUN apt-get install --no-install-recommends -y ca-certificates
RUN apt-get install --no-install-recommends -y curl
RUN apt-get install --no-install-recommends -y gnupg
RUN apt-get install --no-install-recommends -y lsb-release
RUN apt-get install --no-install-recommends -y iptables
RUN apt-get install --no-install-recommends -y libdevmapper1.02.1
WORKDIR /workspace
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
RUN  echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
RUN apt-get update
RUN apt-get install --no-install-recommends -y docker-ce
RUN curl -Os https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce_${DOCKER_VERSION}~3-0~debian-bullseye_amd64.deb

# Download Terraform binary
FROM debian:${DEBIAN_VERSION} as terraform
ARG TERRAFORM_VERSION
RUN apt-get update
RUN apt-get install --no-install-recommends -y curl
RUN apt-get install --no-install-recommends -y ca-certificates
RUN apt-get install --no-install-recommends -y unzip
RUN apt-get install --no-install-recommends -y gnupg
WORKDIR /workspace
RUN curl -Os https://keybase.io/hashicorp/pgp_keys.asc
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
RUN gpg --import hashicorp.asc
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip

# Install AWS CLI using PIP
FROM debian:${DEBIAN_VERSION} as aws-cli
ARG AWS_CLI_VERSION
ARG PYTHON_MAJOR_VERSION
RUN apt-get update
RUN apt-get install -y --no-install-recommends python3=${PYTHON_MAJOR_VERSION}.2-3
RUN apt-get install -y --no-install-recommends python3-pip=20.3.4-4
RUN apt-get install -y groff --no-install-recommends
RUN pip3 install --no-cache-dir setuptools==58.0.4
RUN pip3 install --no-cache-dir awscli==${AWS_CLI_VERSION}
RUN pip3 install saws

# Install aws-nuke
FROM debian:${DEBIAN_VERSION} as aws-nuke
RUN apt-get update
RUN apt-get install --no-install-recommends -y curl
RUN curl -Os https://github.com/rebuy-de/aws-nuke/releases/download/v${AWS_NUKE_VERSION}/aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz
RUN tar xvf aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64.tar.gz
RUN cp aws-nuke-v${AWS_NUKE_VERSION}-linux-amd64 /usr/bin/aws-nuke

# Build final image
FROM debian:${DEBIAN_VERSION}
LABEL maintainer="bgauduch@github"
ARG PYTHON_MAJOR_VERSION
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    ca-certificates=20210119\
    git=1:2.30.2-1 \
    jq=1.6-2.1 \
    python3=${PYTHON_MAJOR_VERSION}.2-3 \
    python3-pip \
    wget \
    zsh \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \
  && update-alternatives --install /usr/bin/python python /usr/bin/python${PYTHON_MAJOR_VERSION} 1

WORKDIR /workspace
COPY --from=terraform /workspace/terraform /usr/local/bin/terraform
COPY --from=docker /usr/bin/docker* /usr/local/bin/
COPY --from=aws-cli /usr/local/bin/aws* /usr/local/bin/
COPY --from=aws-cli /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages /usr/local/lib/python${PYTHON_MAJOR_VERSION}/dist-packages
COPY --from=aws-cli /usr/lib/python3/dist-packages /usr/lib/python3/dist-packages
COPY --from=aws-nuke /usr/bin/aws-nuke /usr/local/bin/aws-nuke

#Install zsh
RUN groupadd --gid 1001 nonroot \
  # user needs a home folder to store aws credentials
  && useradd --gid nonroot --create-home --uid 1001 nonroot \
  && chown nonroot:nonroot /workspace
USER root
RUN sh -c "$(wget https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh -O -)"

ENTRYPOINT ["/usr/bin/bash"]
CMD ["/usr/bin/bash"]
