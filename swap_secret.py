import yaml
import re
import os

# Check if the files exist
def check_files_exist(secret_file, values_file):
    if not os.path.exists(secret_file):
        raise FileNotFoundError(f"The file {secret_file} does not exist.")
    if not os.path.exists(values_file):
        raise FileNotFoundError(f"The file {values_file} does not exist.")

# Load a YAML file
def load_yaml(file_path):
    with open(file_path, 'r') as file:
        return yaml.safe_load(file)

# Save a YAML file with the default dumper
def save_yaml(file_path, data):
    with open(file_path, 'w') as file:
        yaml.dump(data, file, default_flow_style=False, width=float("inf"))

# Apply regex to remove quotes around template expressions
def remove_quotes_around_templates(file_path):
    with open(file_path, 'r') as file:
        content = file.read()

    # Use regex to remove quotes around {{ ... }} expressions
    content = re.sub(r"['\"]({{[^{}]*}})['\"]", r'\1', content)

    # Write the modified content back to the file
    with open(file_path, 'w') as file:
        file.write(content)

# Swap values between secret.yml and values.yml
def swap_values(secret_file, values_file):
    # Check if the files exist
    check_files_exist(secret_file, values_file)

    # Load the YAML files
    secret_data = load_yaml(secret_file)
    values_data = load_yaml(values_file)

    # Extract encrypted data
    secret_encrypted_data = secret_data['spec']['encryptedData']
    values_encrypted_data = values_data['sealedsecrets']['encrypteddata']

    # Create temporary dictionaries for swapping values
    temp_secret = {}
    temp_values = {}

    # Swap values
    for secret_key, secret_value in secret_encrypted_data.items():
        # Convert secret keys to lowercase to match values keys
        values_key = secret_key.lower()

        if values_key in values_encrypted_data:
            # Update temp_values with values from secret.yml
            temp_values[values_key] = secret_value
            # Update temp_secret with values from values.yml without quotes
            template_value = f"{{{{ .Values.sealedsecrets.encrypteddata.{values_key} }}}}"
            temp_secret[secret_key] = template_value

    # Update the data in the files
    secret_data['spec']['encryptedData'] = temp_secret
    values_data['sealedsecrets']['encrypteddata'] = temp_values

    # Save the modified files
    save_yaml(secret_file, secret_data)
    save_yaml(values_file, values_data)

    # Remove quotes around templates in secret.yml
    remove_quotes_around_templates(secret_file)

# Files to process
secret_file = 'secret.yml'
values_file = 'values.yml'

# Call the function to swap values
try:
    swap_values(secret_file, values_file)
    print("")
    print("Values in the files have been successfully swapped.")
except FileNotFoundError as e:
    print(e)
