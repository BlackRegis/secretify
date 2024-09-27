# Secretify

This Bash script automates the process of creating and sealing a Kubernetes secret, and generating a `values.yml` file from a `.env` file. It uses parameters to specify the type of secret, the secret name, and the namespace, and includes a help guide for usage.

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

You can now run the script using either long or short options.

**Long Option Syntax:**

```bash
./main.sh --env-file <path_to_env_file> --secret-type <secret_type> --secret-name <secret_name> --namespace <namespace>
```

**Or short Option Syntax:**

```bash
./main.sh -e <path_to_env_file> -st <secret_type> -sn <secret_name> -n <namespace>
```

- **`<path_to_env_file>`**: Path to the `.env` file containing key-value pairs.
- **`<secret_type>`**: The type of Kubernetes secret to create (e.g., `generic`).
- **`<secret_name>`**: The name of the Kubernetes secret.
- **`<namespace>`**: The namespace in which to create the secret.

**Example:**

```bash
./main.sh --env-file .env --secret-type generic --secret-name keycloak-db-secret --namespace akieni-utility
```

or using short options:

```bash
./main.sh -e .env -st generic -sn keycloak-db-secret -n akieni-utility
```

### Step 4: Display Help

To see a guide on how to use the script, you can run:

```bash
./main.sh --help
```

or

```bash
./main.sh -h
```

## Script Functionality

1. **Help Option**: Displays a help message with usage instructions when `-h` or `--help` is provided.

2. **Loader Animation**: A loading animation is displayed during script execution for visual feedback.

3. **Parameter Checks**: Verifies that the required parameters are provided and that the `.env` file exists. Exits with an error message if any parameter is missing.

4. **Process `.env` File**: Reads the `.env` file, splitting key-value pairs and storing them in an associative array.

5. **Create and Seal Kubernetes Secret**:
   - Uses `kubectl` to create a Kubernetes secret.
   - Seals the secret using `kubeseal` and outputs it to `secret.yml`.

6. **Generate `values.yml`**:
   - Creates a `values.yml` file with the correct structure.
   - Converts keys to lowercase and formats them for use in Helm templates.

7. **Run Python Script**: Executes `swap_secret.py` for further processing.

## Example Output

- **`secret.yml`**: Contains the sealed Kubernetes secret.
- **`values.yml`**: Contains the values in a Helm-compatible format.

## Notes

- Ensure that the `.env` file is formatted correctly with key-value pairs separated by `=`.
- Review the `secret.yml` and `values.yml` files to confirm that the generated content meets your expectations.
- Use the `--help` or `-h` flag to view usage instructions if needed.

## Troubleshooting

- If the `secret.yml` file is not created, check the error message and ensure that all tools are correctly installed and configured.
- Ensure that the Python script `swap_secret.py` is available and executable.
- Verify that the `.env` file exists and is correctly formatted with key-value pairs and always a line break at the end of the file.
