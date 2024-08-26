# OSS Helm Values

![Helm](https://img.shields.io/badge/Helm-3.0+-blue?logo=helm)
![License](https://img.shields.io/badge/license-MIT-green)
![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)

A collection of Helm values for popular open-source tools, designed to simplify the deployment and management of these tools on Kubernetes.

## Table of Contents

- [Overview](#overview)
- [Tools Included](#tools-included)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Overview

This repository contains Helm values files for deploying a variety of open-source tools using Helm charts. Each directory includes a `values.yaml` file specifically tailored to optimize the deployment of the tool in a Kubernetes environment.

## Tools Included

- **[ArgoCD](./ArgoCD):** A declarative, GitOps continuous delivery tool for Kubernetes.
- **[Jenkins](./Jenkins):** The leading open-source automation server.
- **[LGTM](./LGTM/Grafana/):** Grafana LGTM is a lightweight, modular observability platform designed for monitoring and managing logs, metrics, and traces. It stands for Loki, Grafana, Tempo, and Mimir, which are the four core components. 
Currently, only Grafana is distributed. The remaining components will be updated in the future
- **[NeuVector](./neuvector/):** The Kubernetes-native container security platform.
- **[Nginx-Ingress](./Nginx-Ingress/):** An Ingress controller that uses NGINX as a reverse proxy and load balancer.
- **[OpenSearch](./OpenSearch/):** A community-driven, open-source search and analytics suite derived from Elasticsearch.

## Installation

To install any of the Helm charts with these values, follow the instructions below:

1. Add the Helm repository for the tool (if necessary).
2. Navigate to the respective directory.
3. Use the following Helm command to install the chart with the provided values:

```sh
helm install <release-name> <chart-repo>/<chart-name> -f ./<tool>/values.yaml

