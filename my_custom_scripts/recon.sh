#!/bin/bash

# Ask user for the domain
read -p "Enter target domain (e.g., example.com): " TARGET_DOMAIN

# Sanitize the domain for safe filenames (replace . with -)
SAFE_DOMAIN=$(echo "$TARGET_DOMAIN" | tr '.' '-')

# Run subfinder
echo "[*] Running subfinder for $TARGET_DOMAIN..."
subfinder -d "$TARGET_DOMAIN" -silent -o "${SAFE_DOMAIN}_subs.txt"

# Run httpx-toolkit
echo "[*] Probing live hosts with httpx-toolkit..."
httpx-toolkit -l "${SAFE_DOMAIN}_subs.txt" \
  -sc -title -fr -td -ip -mc 200,201,204,301,302,403 \
  -o "live_${SAFE_DOMAIN}.txt"

echo "[+] Recon complete. Results saved to:"
echo "  - Subdomains: ${SAFE_DOMAIN}_subs.txt"
echo "  - Live hosts: live_${SAFE_DOMAIN}.txt"
