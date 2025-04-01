# Subdomain Enumeration Tool v2.0

A powerful and comprehensive subdomain enumeration script that combines multiple tools and techniques to discover subdomains of a target domain.

## Features

- **Multiple Enumeration Modes**:
  - Passive Mode: Quick scan using passive sources
  - Active Mode: Includes port scanning and active enumeration
  - Full Mode: Comprehensive scan with all features

- **Tool Integration**:
  - Core Tools: Sublist3r, Assetfinder, Amass, Subfinder, httprobe
  - Additional Tools: chaos-client, findomain, waybackurls, gau, hakrawler
  - Scanning Tools: nmap, wafw00f, whatweb, masscan, ffuf
  - Advanced Tools: gospider, subjack, httpx, nuclei

- **Output Formats**:
  - Text Report: Simple and readable format
  - JSON Output: Structured data for automation
  - HTML Report: Beautiful and interactive report with charts

- **Advanced Features**:
  - Parallel Processing Support
  - Proxy Support
  - VPN Integration
  - Custom Configuration
  - Progress Tracking
  - Tool Status Monitoring

## Installation

1. Clone the repository:
```bash
git clone https://github.com/LavSarkari/Subdomain-Enumeration-Script.git
cd subdomain-enumeration-tool
```

2. Make the script executable:
```bash
chmod +x subdomain_enumeration.sh
```

3. Run the script (it will automatically install required tools):
```bash
./subdomain_enumeration.sh -d example.com
```

## Usage

### Basic Usage
```bash
./subdomain_enumeration.sh -d example.com
```

### Advanced Usage
```bash
./subdomain_enumeration.sh -d example.com -m full -t 20 -o html -p http://proxy:8080 -v
```

### Command Line Options

| Option | Long Option | Description | Default | Required |
|--------|-------------|-------------|---------|----------|
| `-d` | `--domain` | Target domain to enumerate | None | Yes |
| `-m` | `--mode` | Scan mode: passive/active/full | passive | No |
| `-t` | `--threads` | Number of threads for parallel processing | 10 | No |
| `-o` | `--output` | Output format: text/json/html | text | No |
| `-p` | `--proxy` | Proxy URL for requests | None | No |
| `-v` | `--vpn` | Enable VPN mode | false | No |
| `-c` | `--config` | Custom config file | config.json | No |
| `-h` | `--help` | Show help message | None | No |

### Scan Modes

1. **Passive Mode** (`-m passive`):
   - Quick scan using passive sources
   - Uses tools like Sublist3r, Assetfinder, Amass, Subfinder
   - No direct interaction with target
   - Fastest mode

2. **Active Mode** (`-m active`):
   - Includes port scanning and active enumeration
   - Uses tools like nmap, whatweb, wafw00f
   - Direct interaction with target
   - Moderate speed

3. **Full Mode** (`-m full`):
   - Comprehensive scan with all features
   - Combines passive and active techniques
   - Additional tools like gospider, subjack, nuclei
   - Most thorough but slowest mode

### Output Formats

1. **Text Report** (`-o text`):
   - Simple and readable format
   - Shows statistics and results
   - Easy to parse and process

2. **JSON Output** (`-o json`):
   - Structured data format
   - Suitable for automation
   - Easy to integrate with other tools

3. **HTML Report** (`-o html`):
   - Beautiful and interactive report
   - Includes charts and visualizations
   - Easy to share and view

### Proxy and VPN Support

- **Proxy Support** (`-p http://proxy:8080`):
  - Use HTTP/HTTPS proxy for requests
  - Useful for avoiding rate limits
  - Supports authentication

- **VPN Mode** (`-v`):
  - Enable VPN mode
  - Requires OpenVPN configuration
  - Useful for anonymous scanning

## Output Files

The tool creates the following files in the output directory:

- `subdomains_[domain]/`: Main output directory
  - `all_subdomains.txt`: All discovered subdomains
  - `alive_subdomains.txt`: Verified alive subdomains
  - `analysis.[format]`: Analysis report in specified format
  - Tool-specific output files (e.g., `nmap.txt`, `whatweb.txt`)

## Requirements

- Linux/Unix-based system
- Bash shell
- Internet connection
- Root privileges (for some tool installations)
- Python 3.x (for some tools)
- Go (for some tools)

## Tool Dependencies

The script will automatically install the following tools if missing:

### Core Tools
- Sublist3r
- Assetfinder
- Amass
- Subfinder
- httprobe

### Additional Tools
- chaos-client
- findomain
- waybackurls
- gau
- hakrawler

### Scanning Tools
- nmap
- wafw00f
- whatweb
- masscan
- ffuf

### Advanced Tools
- gospider
- subjack
- httpx
- nuclei

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This tool is for educational and authorized testing purposes only. Always ensure you have permission to scan the target domain.
