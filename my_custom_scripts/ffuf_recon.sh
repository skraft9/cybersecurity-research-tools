#!/bin/bash

# Prompt user for domain and output file
read -p "Enter target domain:" TARGET_DOMAIN

# Run ffuf with provided input
ffuf -u https://$TARGET_DOMAIN/FUZZ \
  -w /usr/share/seclists/Discovery/Web-Content/common.txt \
  -H "X-Bug-Bounty: <USERNAME>" \
  -H "User-Agent: Mozilla/5.0 (BugBounty)" \
  -mc 200,201,204 \
  -fc 404 \
  -recursion \
  -recursion-depth 9 \
  -t 50
