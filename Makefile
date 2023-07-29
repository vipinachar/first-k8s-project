#!/usr/bin/env make
PHONY: run_website delete_website install_kind create_kind_cluster install_kubectl
run_website:
	docker build -t explorecalifornia.com . && \
		docker run -p 5000:80 -d --name explorecalifornia.com --rm explorecalifornia.com

delete_website:
	docker stop explorecalifornia.com

install_kind:
	curl -L -o ./kind https://github.com/kubernetes-sigs/kind/releases/download/v0.20.0/kind-darwin-arm64 && \
		./kind --version

create_kind_cluster: install_kind install_kubectl 
	./kind create cluster --name explorecalifornia.com && \
		kubectl get nodes

install_kubectl: 
	brew install kubectl && \
		kubectl version --client
	