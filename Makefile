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

create_kind_cluster: install_kind install_kubectl  create_docker_registry
	./kind create cluster --name explorecalifornia.com --config ./kind_config.yaml || true  && \
		kubectl get nodes

install_kubectl: 
	brew install kubectl && \
		kubectl version --client

create_docker_registry:
	if docker ps | grep -q local-registry; \
	then echo "local-registry already exists"; \
	else docker run --name local-registry -d --restart=always -p 5000:5000 registry:2; \
	fi
	
connect_registry_to_kind_network:
	docker network connect kind local-registry || true \

connect_registry_to_kind: connect_registry_to_kind_network
	kubectl apply -f ./kind_configmap.yaml \

create_kind_cluster_and_connect_registry:
	$(MAKE) create_kind_cluster && $(MAKE) connect_registry_to_kind

delete_kind_cluster:
	./kind delete cluster --name explorecalifornia.com 

delete_local_docker_registry:
	docker stop local-registry && \
	docker rm local-registry

delete_kind_cluster_and_docker_registry:
	$(MAKE) delete_kind_cluster && $(MAKE) delete_local_docker_registry

install_app:
	helm upgrade --atomic --install explore-california-website ./chart