#!/bin/bash

# Variables
NAMESPACE="opensearch"
CHART_VERSION="2.7.0" # Remplacez par la dernière version si nécessaire
VALUES_DIR="opensearch-config"
VALUES_OPENSEARCH="$VALUES_DIR/opensearch-values.yaml"
VALUES_DASHBOARD="$VALUES_DIR/opensearch-dashboard-values.yaml"

# Crée l'arborescence des répertoires pour les fichiers de configuration
echo "Création de l'arborescence des configurations dans $VALUES_DIR"
mkdir -p "$VALUES_DIR"

# Ajout du dépôt Helm OpenSearch si non existant
if ! helm repo list | grep -q 'opensearch'; then
    echo "Ajout du dépôt Helm OpenSearch"
    helm repo add opensearch https://opensearch-project.github.io/helm-charts/
fi

# Mise à jour des dépôts Helm
echo "Mise à jour des dépôts Helm"
helm repo update

# Fichier de configuration OpenSearch
cat <<EOF >"$VALUES_OPENSEARCH"
clusterName: "opensearch-cluster"
replicaCount: 2
persistence:
  enabled: true
  size: 30Gi
resources:
  requests:
    cpu: "500m"
    memory: "2Gi"
  limits:
    cpu: "1"
    memory: "4Gi"
EOF

# Fichier de configuration OpenSearch Dashboard
cat <<EOF >"$VALUES_DASHBOARD"
replicaCount: 1
opensearchHost: "http://opensearch-cluster-master:9200"
service:
  type: LoadBalancer
resources:
  requests:
    cpu: "250m"
    memory: "500Mi"
  limits:
    cpu: "500m"
    memory: "1Gi"
EOF

# Création du namespace si non existant
kubectl get namespace $NAMESPACE >/dev/null 2>&1 || kubectl create namespace $NAMESPACE

# Installation d'OpenSearch
echo "Installation d'OpenSearch..."
helm install opensearch opensearch/opensearch -n $NAMESPACE -f "$VALUES_OPENSEARCH" --version $CHART_VERSION

# Installation d'OpenSearch Dashboard
echo "Installation d'OpenSearch Dashboard..."
helm install opensearch-dashboards opensearch/opensearch-dashboards -n $NAMESPACE -f "$VALUES_DASHBOARD" --version $CHART_VERSION

echo "Installation complète !"
echo "Configurations sauvegardées dans le dossier $VALUES_DIR"
