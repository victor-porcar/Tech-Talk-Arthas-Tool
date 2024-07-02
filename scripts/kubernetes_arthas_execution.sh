#!/bin/bash

if [ "$#" -ne 3 ]; then
    echo -e "\n"
    echo "Illegal number of parameters."
    echo "USAGE: arthas_execution_kubernetes.sh <KUBERNETES_NAMESPACE> <POD_NAME_PATTERN> <ARTHAS_COMMAND>"
    echo "this command will apply the given <ARTHAS_COMMAND> to all pods belonging to the given Namespace and having given  <POD_NAME_PATTERN> as part of its name"
    echo -e "\n"
    echo 'Example: arthas_execution_kubernetes.sh "my-namespace" "my-pod" "jvm;stop"'
    echo -e "\n"
    exit;
fi

KUBERNETES_NAMESPACE=$1
POD_NAME_PATTERN=$2
ARTHAS_COMMAND=$3

# this is the command that will be executed inside of the pod's shell to obtain 
# java pid for the application to be applied arthas command
 
PID_JAVA_SERVICE="ps -ef | grep -v 'grep java' | grep -v 'arthas-boot.jar' | grep java | awk '{print $"
PID_JAVA_SERVICE="${PID_JAVA_SERVICE}1'}"

POD_NAMES=$( kubectl get pods --namespace "$KUBERNETES_NAMESPACE" | grep -P "$POD_NAME_PATTERN" | cut -d ' ' -f1 )

echo -e "\n"
echo "The following Arthas command:"
echo -e "\n"
echo $ARTHAS_COMMAND
echo -e "\n"
echo "will be applied to the following PODS:"
echo -e "\n"
echo $POD_NAMES  | tr ' ' '\n'  
echo -e "\n"
read -r -p "Are you sure? [y/N] " response
echo -e "\n"

case "$response" in

    [yY][eE][sS]|[yY]) 
        echo $POD_NAMES | tr ' ' '\n' | xargs -tI{} kubectl exec --namespace "$KUBERNETES_NAMESPACE" {} -- bash -c \
        "curl -O https://arthas.aliyun.com/arthas-boot.jar; java -jar arthas-boot.jar -c \"$ARTHAS_COMMAND\" \$($PID_JAVA_SERVICE)" 

        echo "The Arthas command was applied."
        ;;
    *)
        echo "The Arthas command was not applied."
        ;;
esac
