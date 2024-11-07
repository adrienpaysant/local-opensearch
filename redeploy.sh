#!/bin/bash

# Variables
NAMESPACE="opensearch"
CHART_VERSION="2.7.0" # Assurez-vous que cette version est celle voulue (fichier init-repo.sh)
VALUES_DIR="opensearch-config"
VALUES_OPENSEARCH="$VALUES_DIR/opensearch-values.yaml"
VALUES_DASHBOARD="$VALUES_DIR/opensearch-dashboard-values.yaml"

# Vérifie si les fichiers de configuration existent
if [[ ! -f "$VALUES_OPENSEARCH" || ! -f "$VALUES_DASHBOARD" ]]; then
    echo "Les fichiers de configuration nécessaires sont manquants dans $VALUES_DIR"
    echo "Assurez-vous que $VALUES_OPENSEARCH et $VALUES_DASHBOARD existent."
    exit 1
fi

# Mise à jour des dépôts Helm
echo "Mise à jour des dépôts Helm..."
helm repo update

# Redéploiement d'OpenSearch
echo "Redéploiement d'OpenSearch..."
helm upgrade --install opensearch opensearch/opensearch -n $NAMESPACE -f "$VALUES_OPENSEARCH" --version $CHART_VERSION

# Redéploiement d'OpenSearch Dashboard
echo "Redéploiement d'OpenSearch Dashboard..."
helm upgrade --install opensearch-dashboards opensearch/opensearch-dashboards -n $NAMESPACE -f "$VALUES_DASHBOARD" --version $CHART_VERSION

echo "Redéploiement complet !"
