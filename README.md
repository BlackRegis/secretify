# Secretify

This Bash script automates the process of creating and sealing a Kubernetes secret, and generating a `values.yml` file from a `.env` file. It uses parameters to specify the type of secret, the secret name, and the namespace.

## Prerequisites

- **Tools Required:**
  - `kubectl`: Command-line tool for interacting with Kubernetes clusters.
  - `kubeseal`: CLI tool for sealing secrets.
  - `python`: Required to run the `swap_secret.py` script.

- **Files Required:**
  - `.env` file with key-value pairs.
  - `swap_secret.py` Python script.

## Installation

### Step 1: Clone the Repository or Copy the Files

Ensure that the Bash script (`main.sh`), the `.env` file, and the `swap_secret.py` script are in the same directory.

### Step 2: Make the Script Executable

Ensure the Bash script has execute permissions:

```bash
chmod +x main.sh
```

### Step 3: Run the Script

You can execute the script using the following command:

```bash
./main.sh <path_to_env_file> <secret_type> <secret_name> <namespace>
```

- **`<path_to_env_file>`**: Path to the `.env` file containing key-value pairs.
- **`<secret_type>`**: The type of Kubernetes secret to create (e.g., `generic`).
- **`<secret_name>`**: The name of the Kubernetes secret.
- **`<namespace>`**: The namespace in which to create the secret.

**Example:**

```bash
./main.sh .env generic keycloak-db-secret akieni-utility
```

## Script Functionality

1. **Loader Animation**: Displays a loading animation during script execution.

2. **Parameter Checks**: Verifies that a `.env` file is provided and exists. Exits with an error message if not.

3. **Process `.env` File**: Reads the `.env` file, splitting key-value pairs and storing them in an associative array.

4. **Create and Seal Kubernetes Secret**:
   - Uses `kubectl` to create a Kubernetes secret.
   - Seals the secret using `kubeseal` and outputs it to `secret.yml`.

5. **Generate `values.yml`**:
   - Creates a `values.yml` file with the correct structure.
   - Converts keys to lowercase and formats them for use in Helm templates.

6. **Run Python Script**: Executes `swap_secret.py` for further processing.

## Example Output

- **`secret.yml`**: Contains the sealed Kubernetes secret.
- **`values.yml`**: Contains the values in a Helm-compatible format.

## Notes

- Ensure that the `.env` file is formatted correctly with key-value pairs separated by `=`.
- Review the `secret.yml` and `values.yml` files to confirm that the generated content meets your expectations.

## Troubleshooting

- If the `secret.yml` file is not created, check the error message and ensure that all tools are correctly installed and configured.
- Ensure that the Python script `swap_secret.py` is available and executable.
