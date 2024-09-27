#!/bin/bash

# Function to display help manual
usage() {
  echo "Usage: $0 [OPTIONS]"
  echo
  echo "Options:"
  echo "  -e,  --env-file         Path to the environment file (.env)"
  echo "  -st, --secret-type      Type of secret (e.g., generic)"
  echo "  -sn, --secret-name      Name of the secret"
  echo "  -n,  --namespace        Kubernetes namespace"
  echo "  -h,  --help             Display this help message"
  echo
  echo "Example:"
  echo "  $0 --env-file .env --secret-type generic --secret-name keycloak-db-secret --namespace akieni-utility"
  echo "  $0 -e .env -st generic -sn keycloak-db-secret -n akieni-utility"
  echo ""
  echo "This Bash script automates the process of creating and sealing a Kubernetes secret, and generating"
  echo "a values.yml file from a .env file. It uses parameters to specify the type of secret,"
  echo "the secret name, and the namespace."
  exit 0
}

echo
echo "    #     #####  #####    #####  ##### ##### #####  #####  ##### "
echo "   # #    #    # #    #  #       #     #     #   #  #        #   "
echo "  #####   #####  #####    #####  ##### #     #####  #####    #   "
echo " #     #  #      #             # #     #     #  #   #        #   "
echo "#       # #      #        #####  ##### ##### #   #  #####    #   "
echo " _______________________________________________________________"
echo "/__/___/___/___/___/___/___/___/___/___/___/___/___/___/___/___/"
echo

# Default values (if any)
env_file=""
secret_type=""
secret_name=""
namespace=""

# Parse options using getopts and shift for long options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -e|--env-file)
      env_file="$2"
      shift 2
      ;;
    -st|--secret-type)
      secret_type="$2"
      shift 2
      ;;
    -sn|--secret-name)
      secret_name="$2"
      shift 2
      ;;
    -n|--namespace)
      namespace="$2"
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo -e "\033[1;31mError: Invalid option $1\033[m"
      usage
      ;;
  esac
done

# Check if all required parameters are provided
if [ -z "$env_file" ] || [ -z "$secret_type" ] || [ -z "$secret_name" ] || [ -z "$namespace" ]; then
  echo -e "\033[1;31mError: Missing parameters. Use -h or --help for usage information.\033[m"
  exit 1
fi

# Check if the .env file exists
if [ ! -f "$env_file" ]; then
  echo -e "\033[1;31mError: The file $env_file does not exist.\033[m"
  exit 1
fi

# File to be processed
file="$env_file"
Green='\033[0;32m'

# Declare associative array
declare -A associative_array

# Read each line of the file and split the key and value at the first "=" only
while IFS= read -r line; do
  # Check if the line contains an "="
  if [[ "$line" == *=* ]]; then
    # Extract the key (everything before the first "=") and the value (everything after)
    key="${line%%=*}"    # Key: everything before the first "="
    value="${line#*=}"   # Value: everything after "="

    # Clean spaces around keys and values
    key=$(echo "$key" | xargs)
    value=$(echo "$value" | xargs)
    
    # Add the key and value to the associative array
    associative_array["$key"]="$value"
  fi
done < "$file"

# Display the contents of the associative array
echo "Processing in progress ... :"
echo "..."

# Create the secret and encrypt it
kubectl create secret $secret_type $secret_name \
$(for key in "${!associative_array[@]}"; do echo --from-literal="$key=${associative_array[$key]}"; done | xargs) \
-n $namespace --dry-run=client -o json | kubeseal --controller-name=sealed-secrets-controller \
--controller-namespace=flux-system --format yaml > secret.yml

# Check if secret.yml exists
if [ -f secret.yml ]; then
  echo -e "The file \033[1;32msecret.yml\033[m has been created \033[1;32msuccessfully!!!\033[m"
  
  # Generate the values.yml file
  echo "Creating values.yml with the customized structure..."

  # Start of values.yml file
  echo "sealedsecrets:" >> values.yml
  echo "  encrypteddata:" >> values.yml

  # Add each key with the desired structure in values.yml
  for key in "${!associative_array[@]}"; do
    formatted_key=$(echo "$key" | tr '[:upper:]' '[:lower:]')  # Convert to lowercase
    echo "    $formatted_key: '{{ .Values.sealedsecrets.encrypteddata.$formatted_key }}'" >> values.yml
  done

  echo -e "The file \033[1;32mvalues.yml\033[m has been created \033[1;32msuccessfully!!!\033[m"
else
  echo -e "\033[1;31mError: secret.yml file was not created.\033[m"
  exit 1
fi

# Swaping data values between secret.yml and values.yml
python swap_secret.py
