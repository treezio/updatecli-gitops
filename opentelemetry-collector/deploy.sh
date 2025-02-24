#!/bin/sh
NAMESPACE=tracing
CHART_VERSION=0.117.0
APPLICATION="opentelemetry-collector"
ENVIRONMENT=`kubectl config current-context | cut -d- -f1`
DEPLOY=false
TEMPLATE=false

while getopts "dt" arg; do
  case $arg in
    d)
      echo "-d was triggered, Deploying"
      DEPLOY=true
      ;;
    t)
      echo "-t was triggered, Rendering template"
      TEMPLATE=true
      ;;
    *)
      echo "Showing differences"
      ;;
  esac
done

echo "Environment is ${ENVIRONMENT}"

if [ ${DEPLOY} == "true" ]
    then
        ACTION="Upgrading"
        COMMAND="upgrade"
        FLAGS="--atomic --wait --timeout 300s --install ${APPLICATION}"
    elif [ ${TEMPLATE} == true ]
    then
        ACTION="Rendering template"
        COMMAND="template ${APPLICATION}"
        FLAGS=""
    else
        ACTION="Showing differences of"
        COMMAND="diff upgrade --install ${APPLICATION}"
        FLAGS="-C 1"
fi

echo "${ACTION} ${APPLICATION} in namespace ${NAMESPACE}..."

# Adddd helm repository
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update

# install opentelemetry chart
helm ${COMMAND} \
    ${OTEL_PROCESSOR} \
    --namespace=${NAMESPACE} \
    ${FLAGS} \
    -f values.yaml \
    -f values.${ENVIRONMENT}.yaml \
    open-telemetry/opentelemetry-collector --version ${CHART_VERSION}