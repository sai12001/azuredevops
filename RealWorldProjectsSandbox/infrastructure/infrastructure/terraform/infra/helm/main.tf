resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

resource "kubernetes_namespace" "istio_system" {
  metadata {
    name = "istio-system"
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_namespace" "istio_ingress" {
  metadata {
    name = "istio-ingress"
    labels = {
      istio-injection = "enabled"
    }
  }
}
# resource "kubernetes_namespace" "nextgen_dev" {
#   metadata {
#     name = "nextgen-dev"
#     labels = {
#       istio-injection = "enabled"
#     }
#   }
# }

resource "helm_release" "istio_base" {
  name       = "istio-base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "base"

  timeout         = 600
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name
}

resource "helm_release" "istiod" {
  name       = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "istiod"

  timeout         = 600
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  set {
    name  = "meshConfig.accessLogFile"
    value = "/dev/stdout"
  }


  depends_on = [helm_release.istio_base]
}

resource "helm_release" "istio_ingress" {
  name       = "istio-ingressgateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  timeout         = 600
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_ingress.metadata.0.name

  depends_on = [helm_release.istiod]
}

resource "helm_release" "istio_ingress_internal" {
  name       = "istio-ingress-internal"
  repository = "https://istio-release.storage.googleapis.com/charts"
  chart      = "gateway"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_ingress.metadata.0.name

  set {
    name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
    value = "true"
  }

  depends_on = [helm_release.istiod]
}


resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.monitoring.metadata.0.name
  set {
    name  = "alertmanager.persistentVolume.size"
    value = "16Gi"
  }
  set {
    name  = "server.persistentVolume.size"
    value = "16Gi"
  }
  depends_on = [helm_release.istio_base]
}

resource "helm_release" "grafana" {
  name       = "grafana"
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.monitoring.metadata.0.name
  # set {
  #   name  = "service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-internal"
  #   value = "true "
  # }
  depends_on = [helm_release.istio_base]
}


resource "helm_release" "cassandra" {
  name       = "cassandra"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "cassandra"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.monitoring.metadata.0.name
  set {
    name  = "replicaCount"
    value = "2"
  }
  set {
    name  = "persistence.size"
    value = "16Gi"
  }
  depends_on = [helm_release.istio_base]
}

data "kubernetes_secret" "cassandra_secret" {
  metadata {
    name = "cassandra"
    namespace = kubernetes_namespace.monitoring.metadata.0.name
  }
  depends_on = [
    helm_release.cassandra
  ]
}

resource "helm_release" "jaeger" {
  name       = "jaeger"
  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.monitoring.metadata.0.name
  set {
    name  = "provisionDataStore.cassandra"
    value = "false"
  }
  set {
    name  = "storage.cassandra.host"
    value = "cassandra.monitoring.svc.cluster.local"
  }
  set {
    name  = "storage.cassandra.port"
    value = "9042"
  }
  set {
    name  = "storage.cassandra.user"
    value = "cassandra"
  }
  set {
    name  = "storage.cassandra.password"
    value = data.kubernetes_secret.cassandra_secret.data.cassandra-password
  }

  depends_on = [helm_release.cassandra]
}

resource "helm_release" "kiali" {
  name       = "kiali"
  repository = "https://kiali.org/helm-charts"
  chart      = "kiali-server"

  timeout         = 500
  cleanup_on_fail = true
  force_update    = false
  namespace       = kubernetes_namespace.istio_system.metadata.0.name

  set {
    name  = "auth.strategy"
    value = "token"
  }
  set {
    name  = "external_services.prometheus.url"
    value = "http://prometheus-server.monitoring/"
  }
  set {
    name  = "external_services.grafana.enabled"
    value = "true"
  }
  set {
    name  = "external_services.grafana.in_cluster_url"
    value = "http://grafana.monitoring/"
  }
  set {
    name  = "external_services.tracing.enabled"
    value = "true"
  }
  set {
    name  = "external_services.tracing.use_grpc"
    value = "true"
  }
  set {
    name  = "external_services.tracing.in_cluster_url"
    value = "http://jaeger-query.monitoring:16685/jaeger"
  }

  depends_on = [helm_release.istiod,helm_release.jaeger, helm_release.prometheus, helm_release.grafana]
}



# sample appliation