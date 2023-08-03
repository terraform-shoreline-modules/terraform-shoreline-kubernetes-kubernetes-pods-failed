resource "shoreline_notebook" "kubernetes_pods_failed" {
  name       = "kubernetes_pods_failed"
  data       = file("${path.module}/data/kubernetes_pods_failed.json")
  depends_on = [shoreline_action.invoke_get_terminated_pod_status,shoreline_action.invoke_resource_monitoring]
}

resource "shoreline_file" "get_terminated_pod_status" {
  name             = "get_terminated_pod_status"
  input_file       = "${path.module}/data/get_terminated_pod_status.sh"
  md5              = filemd5("${path.module}/data/get_terminated_pod_status.sh")
  description      = "Resource constraints: If a pod exceeds its resource limits, such as CPU or memory, it may be terminated by Kubernetes."
  destination_path = "/agent/scripts/get_terminated_pod_status.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "resource_monitoring" {
  name             = "resource_monitoring"
  input_file       = "${path.module}/data/resource_monitoring.sh"
  md5              = filemd5("${path.module}/data/resource_monitoring.sh")
  description      = "Verify that the Kubernetes cluster has enough resources available for the pods to run. Check CPU, memory, and storage usage, and make sure that the pods are not being starved for resources."
  destination_path = "/agent/scripts/resource_monitoring.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_get_terminated_pod_status" {
  name        = "invoke_get_terminated_pod_status"
  description = "Resource constraints: If a pod exceeds its resource limits, such as CPU or memory, it may be terminated by Kubernetes."
  command     = "`chmod +x /agent/scripts/get_terminated_pod_status.sh && /agent/scripts/get_terminated_pod_status.sh`"
  params      = ["POD_NAME","NAMESPACE"]
  file_deps   = ["get_terminated_pod_status"]
  enabled     = true
  depends_on  = [shoreline_file.get_terminated_pod_status]
}

resource "shoreline_action" "invoke_resource_monitoring" {
  name        = "invoke_resource_monitoring"
  description = "Verify that the Kubernetes cluster has enough resources available for the pods to run. Check CPU, memory, and storage usage, and make sure that the pods are not being starved for resources."
  command     = "`chmod +x /agent/scripts/resource_monitoring.sh && /agent/scripts/resource_monitoring.sh`"
  params      = ["CPU_THRESHOLD","DEPLOYMENT","NAMESPACE","MEMORY_THRESHOLD","STORAGE_THRESHOLD"]
  file_deps   = ["resource_monitoring"]
  enabled     = true
  depends_on  = [shoreline_file.resource_monitoring]
}

