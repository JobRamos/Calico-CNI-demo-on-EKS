# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "null_resource" "eksctl_create" {
  provisioner "local-exec" {
    command = "eksctl create cluster --name my-calico-cluster --without-nodegroup"
  }
}

resource "null_resource" "kubectl_delete" {
  depends_on = [null_resource.eksctl_create]
  provisioner "local-exec" {
    command = "kubectl delete daemonset -n kube-system aws-node"
  }
}

resource "null_resource" "kubectl_apply" {
  depends_on = [null_resource.kubectl_delete]
  provisioner "local-exec" {
    command = "kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.29.3/manifests/tigera-operator.yaml"
  }
}

resource "null_resource" "kubectl_create" {
  depends_on = [null_resource.kubectl_apply]
  provisioner "local-exec" {
    command = "kubectl create -f ${path.module}/create_calico_network.yaml"
  }
}

resource "null_resource" "eksctl_nodegroup" {
  depends_on = [null_resource.kubectl_create]
  provisioner "local-exec" {
    command = "eksctl create nodegroup --cluster my-calico-cluster --node-type t3.medium --max-pods-per-node 100"
  }
}

resource "null_resource" "kubectl_netpol_1" {
  depends_on = [null_resource.eksctl_nodegroup]
  provisioner "local-exec" {
    command = "eksctl create nodegroup --cluster my-calico-cluster --node-type t3.medium --max-pods-per-node 100"
  }
}

# kubectl create deployment nginx-deployment --image=nginx --replicas=30
# calicoctl ipam show
