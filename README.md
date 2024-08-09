# Subdomain Enumeration Script

This script automates the process of subdomain enumeration using multiple tools and techniques. It performs domain reconnaissance by discovering subdomains and checking their availability.

## Features

- Runs multiple subdomain discovery tools including `Sublist3r`, `assetfinder`, `amass`, `Subfinder`, and `crt.sh`.
- Performs DNS brute-forcing using a wordlist.
- Probes discovered subdomains to check for alive hosts.
- Saves the results in organized files.
- **Optional**: Integrates with EyeWitness to take screenshots of alive subdomains.

## Prerequisites

Ensure you have the following tools installed on your system:

- `Sublist3r`
- `assetfinder`
- `amass`
- `Subfinder`
- `crt.sh` (via `curl`)
- `jq`
- `dig`
- `httprobe`
- **Optional**: `EyeWitness` for screenshot functionality

## Installation of Tools

To install the required tools, follow these steps:

1. **Sublist3r**

    ```bash
    pip install sublist3r
    ```

2. **assetfinder**

    ```bash
    go install github.com/tomnomnom/assetfinder@latest
    ```

3. **amass**

    ```bash
    sudo apt-get install amass
    ```

4. **Subfinder**

    ```bash
    go install github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
    ```

5. **crt.sh** (via `curl`)

    `crt.sh` is queried using `curl`, which is commonly pre-installed. Ensure `curl` and `jq` are installed:

    ```bash
    sudo apt-get install curl jq
    ```

6. **dig**

    `dig` is part of the `dnsutils` package:

    ```bash
    sudo apt-get install dnsutils
    ```

7. **httprobe**

    ```bash
    go install github.com/tomnomnom/httprobe@latest
    ```

8. **EyeWitness** (Optional)

    You can install EyeWitness by following the instructions provided in the [EyeWitness GitHub repository](https://github.com/FortyNorthSecurity/EyeWitness).

## Installation

1. Clone the repository:

    ```bash
    git clone https://github.com/yourusername/your-repository.git
    cd your-repository
    ```

2. Ensure the script is executable:

    ```bash
    chmod +x subdomain_enumeration.sh
    ```

## Usage

Run the script by providing the target domain as an argument:

```bash
./subdomain_enumeration.sh example.com
```

This will create an output directory named `subdomains_example.com` and save the results in various files:

- `sublist3r.txt` - Results from Sublist3r
- `assetfinder.txt` - Results from assetfinder
- `amass.txt` - Results from amass
- `subfinder.txt` - Results from Subfinder
- `crtsh.txt` - Results from crt.sh
- `dns_bruteforce.txt` - Results from DNS brute-forcing
- `all_subdomains.txt` - Aggregated list of all discovered subdomains
- `alive_subdomains.txt` - List of alive subdomains

## Optional: EyeWitness Integration

To enhance your reconnaissance, you can integrate EyeWitness to take screenshots of all alive subdomains:

### Add Step 9 to Your Script

Append the following step to the end of your script:

```bash
# Step 9: Run EyeWitness on alive subdomains
echo "[*] Running EyeWitness on alive subdomains..."
EYEWITNESS_DIR="$OUTPUT_DIR/eyewitness"
mkdir -p $EYEWITNESS_DIR
EyeWitness --web -f $ALIVE_FILE -d $EYEWITNESS_DIR --headless
