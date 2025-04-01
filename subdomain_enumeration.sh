#!/bin/bash

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
BOLD='\033[1m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'

# ASCII Art Banner
print_banner() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                            ║"
    echo "║          ___      _         ___                                            ║"
    echo "║         / __|_  _| |__  ___| __|_ _ _  _ _ __                              ║"
    echo "║         \__ \ || | '_ \/ -_) _|| ' \ || | '  \                             ║"
    echo "║         |___/\_,_|_.__/\___|___|_||_\_,_|_|_|_|                            ║"
    echo "║                                                                            ║"
    echo "║         Subdomain Enumeration Tool v2.0                                    ║"
    echo "║                                                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}
#  ___      _         ___                
# / __|_  _| |__  ___| __|_ _ _  _ _ __  
# \__ \ || | '_ \/ -_) _|| ' \ || | '  \ 
# |___/\_,_|_.__/\___|___|_||_\_,_|_|_|_|

# Function to check tool status
check_tool_status() {
    local tool=$1
    local status=""
    local version=""
    
    if command -v "$tool" >/dev/null 2>&1; then
        status="${GREEN}✓${NC}"
        case "$tool" in
            "sublist3r")
                version=$(sublist3r --version 2>/dev/null || echo "installed")
                ;;
            "amass")
                version=$(amass -version 2>/dev/null || echo "installed")
                ;;
            "subfinder")
                version=$(subfinder -version 2>/dev/null || echo "installed")
                ;;
            "nmap")
                version=$(nmap --version | head -n 1)
                ;;
            "whatweb")
                version=$(whatweb --version 2>/dev/null || echo "installed")
                ;;
            *)
                version="installed"
                ;;
        esac
    else
        status="${RED}✗${NC}"
        version="not installed"
    fi
    
    echo -e "${status} ${CYAN}$tool${NC} - ${YELLOW}$version${NC}"
}

# Function to display tool status
display_tool_status() {
    echo -e "\n${BOLD}${MAGENTA}Tool Status:${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
    
    # Core Tools
    echo -e "\n${BOLD}${YELLOW}Core Tools:${NC}"
    check_tool_status "sublist3r"
    check_tool_status "assetfinder"
    check_tool_status "amass"
    check_tool_status "subfinder"
    check_tool_status "httprobe"
    
    # Additional Tools
    echo -e "\n${BOLD}${YELLOW}Additional Tools:${NC}"
    check_tool_status "chaos-client"
    check_tool_status "findomain"
    check_tool_status "waybackurls"
    check_tool_status "gau"
    check_tool_status "hakrawler"
    
    # Scanning Tools
    echo -e "\n${BOLD}${YELLOW}Scanning Tools:${NC}"
    check_tool_status "nmap"
    check_tool_status "wafw00f"
    check_tool_status "whatweb"
    check_tool_status "masscan"
    check_tool_status "ffuf"
    
    # Advanced Tools
    echo -e "\n${BOLD}${YELLOW}Advanced Tools:${NC}"
    check_tool_status "gospider"
    check_tool_status "subjack"
    check_tool_status "httpx"
    check_tool_status "nuclei"
    
    echo -e "\n${BLUE}════════════════════════════════════════════════════════════════════${NC}"
}

# Progress tracking
PROGRESS_FILE=".progress"
CURRENT_TOOL=""
CURRENT_STEP=0
TOTAL_STEPS=0

# Function to run command with timeout
run_with_timeout() {
    local cmd="$1"
    local timeout="$2"
    local tool_name="$3"
    
    echo -e "${YELLOW}[*] Running $tool_name...${NC}"
    
    # Run command with timeout
    timeout "$timeout" bash -c "$cmd" || {
        echo -e "${RED}[!] $tool_name timed out after $timeout seconds${NC}"
        return 1
    }
}

# Function to handle tool execution with retry
run_tool() {
    local cmd="$1"
    local tool_name="$2"
    local max_retries=2
    local timeout=300  # 5 minutes default timeout
    
    for ((i=1; i<=max_retries; i++)); do
        if run_with_timeout "$cmd" "$timeout" "$tool_name"; then
            echo -e "${GREEN}[+] $tool_name completed successfully${NC}"
            return 0
        else
            echo -e "${YELLOW}[!] $tool_name failed (Attempt $i of $max_retries)${NC}"
            sleep 2
        fi
    done
    
    echo -e "${RED}[!] $tool_name failed after $max_retries attempts${NC}"
    return 1
}

# Function to update progress
update_progress() {
    local tool="$1"
    local current="$2"
    local total="$3"
    local percentage=$((current * 100 / total))
    
    CURRENT_TOOL="$tool"
    CURRENT_STEP="$current"
    TOTAL_STEPS="$total"
    
    echo "$percentage" > "$PROGRESS_FILE"
    echo -e "${YELLOW}[*] Progress: [$current/$total] Running $tool...${NC}"
}

# Cleanup function
cleanup() {
    local exit_code=$?
    echo -e "\n${YELLOW}[*] Cleaning up...${NC}"
    
    # Kill any remaining background processes
    jobs -p | xargs -r kill
    
    # Save partial results if they exist
    if [ -d "$OUTPUT_DIR" ]; then
        echo -e "${BLUE}[*] Partial results saved in: $OUTPUT_DIR${NC}"
    fi
    
    # Remove progress file
    rm -f "$PROGRESS_FILE"
    
    exit $exit_code
}

# Set up cleanup trap
trap cleanup EXIT
trap 'echo -e "\n${RED}[!] Script interrupted${NC}"; exit 1' INT TERM

# Default configuration
CONFIG_FILE="config.json"
DEFAULT_MODE="passive"
DEFAULT_THREADS=10
DEFAULT_TIMEOUT=30
DEFAULT_OUTPUT_FORMAT="text"

# Help function
show_help() {
    echo -e "${CYAN}${BOLD}"
    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                                                                            ║"
    echo "║          ___      _         ___                                            ║"
    echo "║         / __|_  _| |__  ___| __|_ _ _  _ _ __                              ║"
    echo "║         \__ \ || | '_ \/ -_) _|| ' \ || | '  \                             ║"
    echo "║         |___/\_,_|_.__/\___|___|_||_\_,_|_|_|_|                            ║"
    echo "║                                                                            ║"
    echo "║         Subdomain Enumeration Tool v2.0                                    ║"
    echo "║                                                                            ║"
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo "Usage: $0 [OPTIONS] -d DOMAIN"
    echo
    echo "Options:"
    echo "  -d, --domain DOMAIN     Target domain (required)"
    echo "  -m, --mode MODE         Scan mode: passive|active|full (default: passive)"
    echo "  -t, --threads N         Number of threads for parallel processing (default: 10)"
    echo "  -o, --output FORMAT     Output format: text|json|html (default: text)"
    echo "  -p, --proxy URL         Proxy URL (optional)"
    echo "  -v, --vpn              Enable VPN mode (requires OpenVPN)"
    echo "  -c, --config FILE      Custom config file (default: config.json)"
    echo "  -h, --help             Show this help message"
    echo
    echo "Modes:"
    echo "  passive: Quick scan using passive sources"
    echo "  active:  Includes port scanning and active enumeration"
    echo "  full:    Comprehensive scan with all features"
    echo
    echo "Example:"
    echo "  $0 -d example.com -m full -t 20 -o html"
    exit 0
}

# Parse command line arguments
parse_args() {
    local domain=""
    local mode="$DEFAULT_MODE"
    local threads="$DEFAULT_THREADS"
    local output="$DEFAULT_OUTPUT_FORMAT"
    local proxy=""
    local vpn=false
    local config="$CONFIG_FILE"

    # Check if no arguments provided or help requested
    if [ $# -eq 0 ] || [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
        show_help
    fi

    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--domain)
                domain="$2"
                shift 2
                ;;
            -m|--mode)
                mode="$2"
                shift 2
                ;;
            -t|--threads)
                threads="$2"
                shift 2
                ;;
            -o|--output)
                output="$2"
                shift 2
                ;;
            -p|--proxy)
                proxy="$2"
                shift 2
                ;;
            -v|--vpn)
                vpn=true
                shift
                ;;
            -c|--config)
                config="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                ;;
            *)
                echo -e "${RED}[!] Unknown option: $1${NC}"
                show_help
                ;;
        esac
    done

    # Validate required arguments
    if [ -z "$domain" ]; then
        echo -e "${RED}[!] Domain is required${NC}"
        show_help
    fi

    # Validate mode
    if [[ ! "$mode" =~ ^(passive|active|full)$ ]]; then
        echo -e "${RED}[!] Invalid mode. Use: passive|active|full${NC}"
        show_help
    fi

    # Validate output format
    if [[ ! "$output" =~ ^(text|json|html)$ ]]; then
        echo -e "${RED}[!] Invalid output format. Use: text|json|html${NC}"
        show_help
    fi

    # Export variables for use in the script
    export DOMAIN="$domain"
    export SCAN_MODE="$mode"
    export THREADS="$threads"
    export OUTPUT_FORMAT="$output"
    export PROXY_URL="$proxy"
    export VPN_MODE="$vpn"
    export CONFIG_FILE="$config"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install required tools
install_tools() {
    local tools=("sublist3r" "assetfinder" "amass" "subfinder" "httprobe" "jq" "chaos-client" "findomain" "waybackurls" "gau" "hakrawler" "nmap" "wafw00f" "whatweb" "masscan" "ffuf" "gospider" "hakrawler" "subjack" "httpx" "nuclei" "gau" "waybackurls" "gospider" "hakrawler" "subjack" "httpx" "nuclei" "gau" "waybackurls" "gospider" "hakrawler" "subjack" "httpx" "nuclei")
    local missing_tools=()
    
    echo -e "${YELLOW}[*] Checking required tools...${NC}"
    
    for tool in "${tools[@]}"; do
        if ! command_exists "$tool"; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${YELLOW}[*] Installing missing tools...${NC}"
        
        # Check package manager
        if command_exists apt-get; then
            sudo apt-get update
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "sublist3r")
                        sudo apt-get install -y python3-pip
                        pip3 install sublist3r
                        ;;
                    "assetfinder")
                        sudo apt-get install -y golang-go
                        go install github.com/tomnomnom/assetfinder@latest
                        ;;
                    "amass")
                        sudo apt-get install -y amass
                        ;;
                    "subfinder")
                        sudo apt-get install -y golang-go
                        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                        ;;
                    "httprobe")
                        sudo apt-get install -y golang-go
                        go install github.com/tomnomnom/httprobe@latest
                        ;;
                    "jq")
                        sudo apt-get install -y jq
                        ;;
                    "chaos-client")
                        sudo apt-get install -y golang-go
                        go install github.com/projectdiscovery/chaos-client/cmd/chaos@latest
                        ;;
                    "findomain")
                        curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux
                        chmod +x findomain-linux
                        sudo mv findomain-linux /usr/bin/findomain
                        ;;
                    "waybackurls")
                        sudo apt-get install -y golang-go
                        go install github.com/tomnomnom/waybackurls@latest
                        ;;
                    "gau")
                        sudo apt-get install -y golang-go
                        go install github.com/lc/gau/v2/cmd/gau@latest
                        ;;
                    "hakrawler")
                        sudo apt-get install -y golang-go
                        go install github.com/hakluke/hakrawler@latest
                        ;;
                    "nmap")
                        sudo apt-get install -y nmap
                        ;;
                    "wafw00f")
                        sudo apt-get install -y python3-pip
                        pip3 install wafw00f
                        ;;
                    "whatweb")
                        sudo apt-get install -y whatweb
                        ;;
                    "masscan")
                        sudo apt-get install -y masscan
                        ;;
                    "ffuf")
                        sudo apt-get install -y golang-go
                        go install github.com/ffuf/ffuf@latest
                        ;;
                    "gospider")
                        sudo apt-get install -y golang-go
                        go install github.com/jaeles-project/gospider@latest
                        ;;
                    "subjack")
                        sudo apt-get install -y golang-go
                        go install github.com/haccer/subjack@latest
                        ;;
                    "httpx")
                        sudo apt-get install -y golang-go
                        go install github.com/projectdiscovery/httpx/cmd/httpx@latest
                        ;;
                    "nuclei")
                        sudo apt-get install -y golang-go
                        go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
                        ;;
                esac
            done
        elif command_exists yum; then
            sudo yum update
            for tool in "${missing_tools[@]}"; do
                case $tool in
                    "sublist3r")
                        sudo yum install -y python3-pip
                        pip3 install sublist3r
                        ;;
                    "assetfinder")
                        sudo yum install -y golang
                        go install github.com/tomnomnom/assetfinder@latest
                        ;;
                    "amass")
                        sudo yum install -y amass
                        ;;
                    "subfinder")
                        sudo yum install -y golang
                        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
                        ;;
                    "httprobe")
                        sudo yum install -y golang
                        go install github.com/tomnomnom/httprobe@latest
                        ;;
                    "jq")
                        sudo yum install -y jq
                        ;;
                    "chaos-client")
                        sudo yum install -y golang
                        go install github.com/projectdiscovery/chaos-client/cmd/chaos@latest
                        ;;
                    "findomain")
                        curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux
                        chmod +x findomain-linux
                        sudo mv findomain-linux /usr/bin/findomain
                        ;;
                    "waybackurls")
                        sudo yum install -y golang
                        go install github.com/tomnomnom/waybackurls@latest
                        ;;
                    "gau")
                        sudo yum install -y golang
                        go install github.com/lc/gau/v2/cmd/gau@latest
                        ;;
                    "hakrawler")
                        sudo yum install -y golang
                        go install github.com/hakluke/hakrawler@latest
                        ;;
                    "nmap")
                        sudo yum install -y nmap
                        ;;
                    "wafw00f")
                        sudo yum install -y python3-pip
                        pip3 install wafw00f
                        ;;
                    "whatweb")
                        sudo yum install -y whatweb
                        ;;
                    "masscan")
                        sudo yum install -y masscan
                        ;;
                    "ffuf")
                        sudo yum install -y golang
                        go install github.com/ffuf/ffuf@latest
                        ;;
                    "gospider")
                        sudo yum install -y golang
                        go install github.com/jaeles-project/gospider@latest
                        ;;
                    "subjack")
                        sudo yum install -y golang
                        go install github.com/haccer/subjack@latest
                        ;;
                    "httpx")
                        sudo yum install -y golang
                        go install github.com/projectdiscovery/httpx/cmd/httpx@latest
                        ;;
                    "nuclei")
                        sudo yum install -y golang
                        go install github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
                        ;;
                esac
            done
        else
            echo -e "${RED}[!] Unsupported package manager. Please install the following tools manually:${NC}"
            printf '%s\n' "${missing_tools[@]}"
            exit 1
        fi
    fi
}

# Function to check if a domain is valid
is_valid_domain() {
    local domain=$1
    # Debug output
    echo -e "${YELLOW}[*] Validating domain: $domain${NC}"
    
    # Basic checks
    if [ -z "$domain" ]; then
        echo -e "${RED}[!] Domain cannot be empty${NC}"
        return 1
    fi
    
    if [[ ! "$domain" =~ \. ]]; then
        echo -e "${RED}[!] Domain must contain at least one dot${NC}"
        return 1
    fi
    
    if [[ "$domain" =~ ^[[:space:]]+|[[:space:]]+$ ]]; then
        echo -e "${RED}[!] Domain cannot contain leading or trailing spaces${NC}"
        return 1
    fi
    
    # Check if domain is resolvable
    if ! dig +short "$domain" >/dev/null 2>&1; then
        echo -e "${YELLOW}[!] Warning: Domain is not resolvable, but continuing anyway...${NC}"
    else
        echo -e "${GREEN}[+] Domain is resolvable${NC}"
    fi
    
    return 0
}

# Function to append and sort unique subdomains
append_unique_subdomains() {
    local input_file=$1
    if [ -n "$input_file" ] && [ -f "$input_file" ]; then
        cat "$input_file" >> "$ALL_SUBDOMAINS_FILE"
    else
        cat >> "$ALL_SUBDOMAINS_FILE"
    fi
    sort -u "$ALL_SUBDOMAINS_FILE" -o "$ALL_SUBDOMAINS_FILE"
}

# Function to check if a tool execution was successful
check_execution() {
    if [ $? -ne 0 ]; then
        echo -e "${RED}[!] Error: $1 failed${NC}"
        return 1
    fi
    return 0
}

# Function to show progress
show_progress() {
    local tool=$1
    local current=$2
    local total=$3
    echo -e "${YELLOW}[*] Progress: [$current/$total] Running $tool...${NC}"
}

# Function to run passive enumeration
run_passive_enumeration() {
    echo -e "${BLUE}[*] Starting passive enumeration...${NC}"
    local total_tools=7
    
    # Step 1: Sublist3r
    update_progress "Sublist3r" 1 $total_tools
    run_tool "sublist3r -d \"$DOMAIN\" -o \"$OUTPUT_DIR/sublist3r.txt\"" "Sublist3r"
    [ -f "$OUTPUT_DIR/sublist3r.txt" ] && append_unique_subdomains "$OUTPUT_DIR/sublist3r.txt"
    
    # Step 2: assetfinder
    update_progress "assetfinder" 2 $total_tools
    run_tool "assetfinder --subs-only \"$DOMAIN\" > \"$OUTPUT_DIR/assetfinder.txt\"" "assetfinder"
    [ -f "$OUTPUT_DIR/assetfinder.txt" ] && append_unique_subdomains "$OUTPUT_DIR/assetfinder.txt"
    
    # Step 3: amass (with reduced scope for faster results)
    update_progress "amass" 3 $total_tools
    run_tool "amass enum -timeout 10 -d \"$DOMAIN\" -o \"$OUTPUT_DIR/amass.txt\"" "amass"
    [ -f "$OUTPUT_DIR/amass.txt" ] && append_unique_subdomains "$OUTPUT_DIR/amass.txt"
    
    # Step 4: Subfinder
    update_progress "Subfinder" 4 $total_tools
    run_tool "subfinder -d \"$DOMAIN\" -o \"$OUTPUT_DIR/subfinder.txt\"" "Subfinder"
    [ -f "$OUTPUT_DIR/subfinder.txt" ] && append_unique_subdomains "$OUTPUT_DIR/subfinder.txt"
    
    # Step 5: crt.sh
    update_progress "crt.sh" 5 $total_tools
    run_tool "curl -s \"https://crt.sh/?q=%25.$DOMAIN&output=json\" | jq -r '.[].name_value' | sed 's/\\*\\.//g' > \"$OUTPUT_DIR/crtsh.txt\"" "crt.sh"
    [ -f "$OUTPUT_DIR/crtsh.txt" ] && append_unique_subdomains "$OUTPUT_DIR/crtsh.txt"
    
    # Step 6: chaos-client
    update_progress "chaos-client" 6 $total_tools
    run_tool "chaos -d \"$DOMAIN\" -o \"$OUTPUT_DIR/chaos.txt\"" "chaos-client"
    [ -f "$OUTPUT_DIR/chaos.txt" ] && append_unique_subdomains "$OUTPUT_DIR/chaos.txt"
    
    # Step 7: findomain
    update_progress "findomain" 7 $total_tools
    run_tool "findomain -t \"$DOMAIN\" --quiet -o \"$OUTPUT_DIR/findomain.txt\"" "findomain"
    [ -f "$OUTPUT_DIR/findomain.txt" ] && append_unique_subdomains "$OUTPUT_DIR/findomain.txt"
    
    echo -e "${GREEN}[+] Passive enumeration completed${NC}"
}

# Function to run active enumeration
run_active_enumeration() {
    echo -e "${BLUE}[*] Starting active enumeration...${NC}"
    local total_tools=4
    
    # Step 1: Port scanning with nmap
    update_progress "nmap" 1 $total_tools
    run_tool "nmap -sS -sV -p- -T4 -iL \"$ALL_SUBDOMAINS_FILE\" -oN \"$OUTPUT_DIR/nmap.txt\"" "nmap"
    
    # Step 2: Technology detection
    update_progress "whatweb" 2 $total_tools
    run_tool "whatweb -i \"$ALIVE_FILE\" -o \"$OUTPUT_DIR/whatweb.txt\"" "whatweb"
    
    # Step 3: WAF detection
    update_progress "wafw00f" 3 $total_tools
    run_tool "wafw00f -i \"$ALIVE_FILE\" -o \"$OUTPUT_DIR/wafw00f.txt\"" "wafw00f"
    
    # Step 4: Directory bruteforce
    update_progress "ffuf" 4 $total_tools
    run_tool "ffuf -u \"https://FUZZ.$DOMAIN\" -w \"$WORDLIST\" -o \"$OUTPUT_DIR/ffuf.txt\"" "ffuf"
    
    echo -e "${GREEN}[+] Active enumeration completed${NC}"
}

# Function to run full enumeration
run_full_enumeration() {
    echo -e "${BLUE}[*] Starting full enumeration...${NC}"
    
    # Run passive enumeration
    run_passive_enumeration
    
    # Run active enumeration
    run_active_enumeration
    
    # Additional steps for full mode
    echo -e "${YELLOW}[*] Running additional enumeration steps...${NC}"
    local total_tools=5
    
    # Step 1: URL discovery
    update_progress "gau" 1 $total_tools
    run_tool "gau \"$DOMAIN\" > \"$OUTPUT_DIR/gau.txt\"" "gau"
    
    # Step 2: Wayback machine URLs
    update_progress "waybackurls" 2 $total_tools
    run_tool "waybackurls \"$DOMAIN\" > \"$OUTPUT_DIR/waybackurls.txt\"" "waybackurls"
    
    # Step 3: Spider crawling
    update_progress "gospider" 3 $total_tools
    run_tool "gospider -s \"https://$DOMAIN\" -o \"$OUTPUT_DIR/gospider\"" "gospider"
    
    # Step 4: Subdomain takeover check
    update_progress "subjack" 4 $total_tools
    run_tool "subjack -w \"$ALL_SUBDOMAINS_FILE\" -t 100 -timeout 30 -o \"$OUTPUT_DIR/subjack.txt\"" "subjack"
    
    # Step 5: Vulnerability scanning
    update_progress "nuclei" 5 $total_tools
    run_tool "nuclei -l \"$ALIVE_FILE\" -o \"$OUTPUT_DIR/nuclei.txt\"" "nuclei"
    
    echo -e "${GREEN}[+] Full enumeration completed${NC}"
}

# Function to generate reports
generate_report() {
    echo -e "${YELLOW}[*] Generating analysis report...${NC}"
    
    if [ "$OUTPUT_FORMAT" = "html" ]; then
        # Generate HTML report
        {
            echo "<!DOCTYPE html>"
            echo "<html><head>"
            echo "<title>Subdomain Enumeration Report - $DOMAIN</title>"
            echo "<style>"
            echo "body { font-family: Arial, sans-serif; margin: 20px; }"
            echo "h1 { color: #2c3e50; }"
            echo "h2 { color: #34495e; }"
            echo ".section { margin: 20px 0; padding: 10px; border: 1px solid #ddd; }"
            echo ".success { color: green; }"
            echo ".warning { color: orange; }"
            echo ".error { color: red; }"
            echo "</style>"
            echo "</head><body>"
            echo "<h1>Subdomain Enumeration Report</h1>"
            echo "<div class='section'>"
            echo "<h2>Target Domain</h2>"
            echo "<p>$DOMAIN</p>"
            echo "</div>"
            echo "<div class='section'>"
            echo "<h2>Scan Information</h2>"
            echo "<p>Scan Date: $(date)</p>"
            echo "<p>Scan Mode: $SCAN_MODE</p>"
            echo "</div>"
            echo "<div class='section'>"
            echo "<h2>Statistics</h2>"
            echo "<p>Total Unique Subdomains: $(wc -l < "$ALL_SUBDOMAINS_FILE")</p>"
            echo "<p>Alive Subdomains: $(wc -l < "$ALIVE_FILE")</p>"
            echo "</div>"
            echo "<div class='section'>"
            echo "<h2>Tool Results</h2>"
            echo "<ul>"
            echo "<li>Sublist3r: $(wc -l < "$OUTPUT_DIR/sublist3r.txt") subdomains</li>"
            echo "<li>Assetfinder: $(wc -l < "$OUTPUT_DIR/assetfinder.txt") subdomains</li>"
            echo "<li>Amass: $(wc -l < "$OUTPUT_DIR/amass.txt") subdomains</li>"
            echo "<li>Subfinder: $(wc -l < "$OUTPUT_DIR/subfinder.txt") subdomains</li>"
            echo "<li>crt.sh: $(wc -l < "$OUTPUT_DIR/crtsh.txt") subdomains</li>"
            echo "</ul>"
            echo "</div>"
            echo "<div class='section'>"
            echo "<h2>Alive Subdomains</h2>"
            echo "<pre>"
            cat "$ALIVE_FILE"
            echo "</pre>"
            echo "</div>"
            echo "</body></html>"
        } > "$ANALYSIS_FILE"
    else
        # Generate text report
        {
            echo "=== Subdomain Enumeration Analysis Report ==="
            echo "Target Domain: $DOMAIN"
            echo "Scan Date: $(date)"
            echo ""
            echo "=== Statistics ==="
            echo "Total Unique Subdomains Found: $(wc -l < "$ALL_SUBDOMAINS_FILE")"
            echo "Alive Subdomains: $(wc -l < "$ALIVE_FILE")"
            echo ""
            echo "=== Tool Results ==="
            echo "Sublist3r: $(wc -l < "$OUTPUT_DIR/sublist3r.txt") subdomains"
            echo "Assetfinder: $(wc -l < "$OUTPUT_DIR/assetfinder.txt") subdomains"
            echo "Amass: $(wc -l < "$OUTPUT_DIR/amass.txt") subdomains"
            echo "Subfinder: $(wc -l < "$OUTPUT_DIR/subfinder.txt") subdomains"
            echo "crt.sh: $(wc -l < "$OUTPUT_DIR/crtsh.txt") subdomains"
            echo ""
            echo "=== Alive Subdomains ==="
            cat "$ALIVE_FILE"
        } > "$ANALYSIS_FILE"
    fi
}

# Main script
# Check for help flag first
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [ $# -eq 0 ]; then
    show_help
    exit 0
fi

# Only proceed with the rest of the script if not showing help
print_banner
display_tool_status

# Parse command line arguments
parse_args "$@"

# Validate domain
if ! is_valid_domain "$DOMAIN"; then
    echo -e "${RED}[!] Error: Invalid domain format${NC}"
    exit 1
fi

# Set up output directory
OUTPUT_DIR="subdomains_$DOMAIN"
ALIVE_FILE="$OUTPUT_DIR/alive_subdomains.txt"
ALL_SUBDOMAINS_FILE="$OUTPUT_DIR/all_subdomains.txt"
ANALYSIS_FILE="$OUTPUT_DIR/analysis.$OUTPUT_FORMAT"
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"

# Create output directory and files
echo -e "${BLUE}[*] Setting up output directory...${NC}"
mkdir -p "$OUTPUT_DIR"
touch "$ALL_SUBDOMAINS_FILE"
touch "$ALIVE_FILE"

# Install required tools
echo -e "${BLUE}[*] Checking and installing required tools...${NC}"
install_tools

# Display scan configuration
echo -e "\n${BOLD}${MAGENTA}Scan Configuration:${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Target Domain:${NC} ${YELLOW}$DOMAIN${NC}"
echo -e "${CYAN}Scan Mode:${NC} ${YELLOW}$SCAN_MODE${NC}"
echo -e "${CYAN}Threads:${NC} ${YELLOW}$THREADS${NC}"
echo -e "${CYAN}Output Format:${NC} ${YELLOW}$OUTPUT_FORMAT${NC}"
[ -n "$PROXY_URL" ] && echo -e "${CYAN}Proxy:${NC} ${YELLOW}$PROXY_URL${NC}"
[ "$VPN_MODE" = true ] && echo -e "${CYAN}VPN Mode:${NC} ${YELLOW}Enabled${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}\n"

# Start enumeration based on mode
case "$SCAN_MODE" in
    "passive")
        run_passive_enumeration
        ;;
    "active")
        run_active_enumeration
        ;;
    "full")
        run_full_enumeration
        ;;
esac

# Probe for alive subdomains
echo -e "${YELLOW}[*] Probing for alive subdomains...${NC}"
cat "$ALL_SUBDOMAINS_FILE" | httprobe -c "$THREADS" | tee "$ALIVE_FILE"
check_execution "httprobe"

# Generate report
generate_report

# Display final results
echo -e "\n${BOLD}${MAGENTA}Scan Results:${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}Total Subdomains Found:${NC} ${YELLOW}$(wc -l < "$ALL_SUBDOMAINS_FILE")${NC}"
echo -e "${CYAN}Alive Subdomains:${NC} ${YELLOW}$(wc -l < "$ALIVE_FILE")${NC}"
echo -e "${CYAN}Results Directory:${NC} ${YELLOW}$OUTPUT_DIR${NC}"
echo -e "${CYAN}Analysis Report:${NC} ${YELLOW}$ANALYSIS_FILE${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════════${NC}"

echo -e "\n${GREEN}[+] Enumeration completed successfully!${NC}"
echo -e "${BLUE}[*] Results saved in: $OUTPUT_DIR${NC}"
echo -e "${BLUE}[*] Analysis report: $ANALYSIS_FILE${NC}"
echo -e "${BLUE}[*] Alive subdomains: $ALIVE_FILE${NC}"
echo -e "${BLUE}[*] All subdomains: $ALL_SUBDOMAINS_FILE${NC}"
