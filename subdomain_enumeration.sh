#!/bin/bash

# Check if domain is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <domain>"
    exit 1
fi

DOMAIN=$1
OUTPUT_DIR="subdomains_$DOMAIN"
ALIVE_FILE="$OUTPUT_DIR/alive_subdomains.txt"
ALL_SUBDOMAINS_FILE="$OUTPUT_DIR/all_subdomains.txt"

# Create output directory
mkdir -p $OUTPUT_DIR

# Function to append and sort unique subdomains
append_unique_subdomains() {
    cat >> $ALL_SUBDOMAINS_FILE
    sort -u $ALL_SUBDOMAINS_FILE -o $ALL_SUBDOMAINS_FILE
}

# Step 1: Sublist3r
echo "[*] Running Sublist3r..."
sublist3r -d $DOMAIN -o "$OUTPUT_DIR/sublist3r.txt"

if [ -f "$OUTPUT_DIR/sublist3r.txt" ]; then
    cat "$OUTPUT_DIR/sublist3r.txt" | append_unique_subdomains
else
    echo "[!] Warning: Sublist3r did not create an output file. Skipping Sublist3r results."
fi

# Step 2: assetfinder
echo "[*] Running assetfinder..."
assetfinder --subs-only $DOMAIN | tee "$OUTPUT_DIR/assetfinder.txt" | append_unique_subdomains

# Step 3: amass
echo "[*] Running amass..."
amass enum -d $DOMAIN -o "$OUTPUT_DIR/amass.txt"
cat "$OUTPUT_DIR/amass.txt" | append_unique_subdomains

# Step 4: Subfinder
echo "[*] Running Subfinder..."
subfinder -d $DOMAIN -o "$OUTPUT_DIR/subfinder.txt"
cat "$OUTPUT_DIR/subfinder.txt" | append_unique_subdomains

# Step 5: crt.sh (using curl)
echo "[*] Querying crt.sh..."
curl -s "https://crt.sh/?q=%25.$DOMAIN&output=json" | jq -r '.[].name_value' | sed 's/\*\.//g' | tee "$OUTPUT_DIR/crtsh.txt" | append_unique_subdomains

# Step 6: Brute-force subdomains using a wordlist and dig
WORDLIST="/usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt"  # Replace with your preferred wordlist
echo "[*] Running DNS brute force..."
while read -r subdomain; do
    FULL_SUBDOMAIN="$subdomain.$DOMAIN"
    if dig +short $FULL_SUBDOMAIN | grep -q '\.'; then
        echo $FULL_SUBDOMAIN
    fi
done < $WORDLIST | tee -a "$OUTPUT_DIR/dns_bruteforce.txt" | append_unique_subdomains

# Step 7: Sort all found subdomains and remove duplicates
sort -u $ALL_SUBDOMAINS_FILE -o $ALL_SUBDOMAINS_FILE
echo "[*] All subdomains saved to $ALL_SUBDOMAINS_FILE"

# Step 8: Probe for alive subdomains
echo "[*] Probing for alive subdomains..."
cat $ALL_SUBDOMAINS_FILE | httprobe -c 50 | tee $ALIVE_FILE
echo "[*] Alive subdomains saved to $ALIVE_FILE"

echo "[*] Subdomain enumeration completed."
