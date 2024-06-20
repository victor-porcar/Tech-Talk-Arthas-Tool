#!/bin/bash

if [ "$#" -ne 3 ]; then
	echo -e "\n"
    echo "Illegal number of parameters."
    echo "USAGE: upload_file_kubernetes.sh <LOCAL_FILE_PATH> <POD_NAME_PATTERN> <POD_FILE_PATH>"
    echo "this command will upload the given local file on path <LOCAL_FILE_PATH> to the path <POD_FILE_PATH> of"
    echo "all pods having in its name the string <POD_NAME_PATTERN>"
    echo -e "\n"
    echo 'Example: upload_file_kubernetes.sh "/home/my_user/Test.class" "my-pod" "/tmp"'
    echo -e "\n"
    exit;
fi

LOCAL_FILE_PATH=$1
POD_NAME_PATTERN=$2
POD_FILE_PATH=$3


POD_NAMES=$( kubectl get pods   | grep -P $POD_NAME_PATTERN | cut -d ' ' -f1 )

echo -e "\n"
echo "The local file $LOCAL_FILE_PATH will be uploaded to the path $POD_FILE_PATH of the following pods:"
echo -e "\n"
echo $POD_NAMES  | tr ' ' '\n'  
echo -e "\n"
read -r -p "Are you sure? [y/N] " response
echo -e "\n"

case "$response" in

    [yY][eE][sS]|[yY]) 
        echo $POD_NAMES | tr ' ' '\n' | xargs -tI{} \
        kubectl   cp  $LOCAL_FILE_PATH {}:$POD_FILE_PATH

        echo "The file has been uploaded."
        ;;
    *)
        echo "The file won't be uploaded."
        ;;
esac

