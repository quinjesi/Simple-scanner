#!/bin/bash

# Set up the project name and base directory
PROJECT_NAME="vulnerability_scanner"
BASE_DIR=$(pwd)/$PROJECT_NAME
SECLISTS_DIR="/usr/share/seclists"

# Function to create directories
create_directories() {
    echo "Creating directory structure..."
    mkdir -p $BASE_DIR/{scanners,payloads/{sql_injection,xss,directory_traversal,lfi},reports,logs}
}

# Function to copy payloads from SecLists
copy_payloads() {
    echo "Copying payloads from SecLists..."

    cp $SECLISTS_DIR/Fuzzing/SQLi.txt $BASE_DIR/payloads/sql_injection/ || echo "SQLi payloads not found"
    cp $SECLISTS_DIR/Fuzzing/XSS.txt $BASE_DIR/payloads/xss/ || echo "XSS payloads not found"
    cp $SECLISTS_DIR/Fuzzing/LFI/LFI.txt $BASE_DIR/payloads/lfi/ || echo "LFI payloads not found"
    cp $SECLISTS_DIR/Discovery/Web-Content/common.txt $BASE_DIR/payloads/directory_traversal/ || echo "Directory Traversal payloads not found"
}

# Function to create the __init__.py files for Python packages
create_init_py() {
    echo "Creating __init__.py files..."
    touch $BASE_DIR/scanners/__init__.py
}

# Function to create the payload loader module
create_payload_loader() {
    echo "Creating payload_loader.py..."
    cat > $BASE_DIR/scanners/payload_loader.py <<EOL
import glob

def load_payloads(directory):
    payloads = []
    for file in glob.glob(f"{directory}/*.txt"):
        with open(file, 'r') as f:
            payloads.extend(f.read().splitlines())
    return payloads
EOL
}

# Function to create the request engine module
create_request_engine() {
    echo "Creating request_engine.py..."
    cat > $BASE_DIR/scanners/request_engine.py <<EOL
import requests

def send_request(url, payload, headers=None, proxy=None):
    try:
        response = requests.get(url, params=payload, headers=headers, timeout=10, proxies=proxy)
        return response
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
        return None
EOL
}

# Function to create the SQL Injection scanner module
create_sql_injection_scanner() {
    echo "Creating sql_injection_scanner.py..."
    cat > $BASE_DIR/scanners/sql_injection_scanner.py <<EOL
from .payload_loader import load_payloads
from .request_engine import send_request
import logging

def scan_sql_injection(url):
    payloads = load_payloads('payloads/sql_injection/')
    for payload in payloads:
        response = send_request(url, {'input': payload})
        if response and "SQL syntax" in response.text:
            logging.info(f"SQL Injection detected at {url} with payload {payload}")
            return True
    return False
EOL
}

# Function to create the XSS scanner module
create_xss_scanner() {
    echo "Creating xss_scanner.py..."
    cat > $BASE_DIR/scanners/xss_scanner.py <<EOL
from .payload_loader import load_payloads
from .request_engine import send_request
import logging

def scan_xss(url):
    payloads = load_payloads('payloads/xss/')
    for payload in payloads:
        response = send_request(url, {'input': payload})
        if response and payload in response.text:
            logging.info(f"XSS detected at {url} with payload {payload}")
            return True
    return False
EOL
}

# Function to create the Directory Traversal scanner module
create_directory_traversal_scanner() {
    echo "Creating directory_traversal_scanner.py..."
    cat > $BASE_DIR/scanners/directory_traversal_scanner.py <<EOL
from .payload_loader import load_payloads
from .request_engine import send_request
import logging

def scan_directory_traversal(url):
    payloads = load_payloads('payloads/directory_traversal/')
    for payload in payloads:
        response = send_request(url, {'file': payload})
        if response and "root:x:" in response.text:
            logging.info(f"Directory Traversal detected at {url} with payload {payload}")
            return True
    return False
EOL
}

# Function to create the LFI scanner module
create_lfi_scanner() {
    echo "Creating lfi_scanner.py..."
    cat > $BASE_DIR/scanners/lfi_scanner.py <<EOL
from .payload_loader import load_payloads
from .request_engine import send_request
import logging

def scan_lfi(url):
    payloads = load_payloads('payloads/lfi/')
    for payload in payloads:
        response = send_request(url, {'file': payload})
        if response and "root:x:" in response.text:
            logging.info(f"LFI detected at {url} with payload {payload}")
            return True
    return False
EOL
}

# Function to create the main.py file
create_main_py() {
    echo "Creating main.py..."
    cat > $BASE_DIR/main.py <<EOL
import logging
from scanners.sql_injection_scanner import scan_sql_injection
from scanners.xss_scanner import scan_xss
from scanners.directory_traversal_scanner import scan_directory_traversal
from scanners.lfi_scanner import scan_lfi

# Set up logging
logging.basicConfig(filename='logs/scan_results.log', level=logging.INFO)

def main():
    urls = ["http://example.com/test.php", "http://example.com/login.php"]  # Example URLs

    for url in urls:
        print(f"Scanning {url} for vulnerabilities...")
        if scan_sql_injection(url):
            print(f"SQL Injection found at {url}")
        if scan_xss(url):
            print(f"XSS found at {url}")
        if scan_directory_traversal(url):
            print(f"Directory Traversal found at {url}")
        if scan_lfi(url):
            print(f"LFI found at {url}")

if __name__ == "__main__":
    main()
EOL
}

# Function to create the README.md file
create_readme_md() {
    echo "Creating README.md..."
    cat > $BASE_DIR/README.md <<EOL
# Vulnerability Scanner

This project is a comprehensive vulnerability scanner built with Python and Bash. It leverages various payloads to detect common web application vulnerabilities such as SQL Injection, XSS, Directory Traversal, and Local File Inclusion (LFI).

## Project Structure

- \`scanners/\`: Contains the scanner modules for different vulnerabilities.
- \`payloads/\`: Directory for storing payloads used in the scans.
- \`reports/\`: Directory where scan reports are generated.
- \`logs/\`: Directory for log files.
- \`main.py\`: The main script that runs the scanner.
- \`README.md\`: This documentation file.

## How to Run

1. Clone the repository:
   \`\`\`bash
   git clone https://github.com/yourusername/vulnerability_scanner.git
   \`\`\`

2. Install the required Python packages:
   \`\`\`bash
   pip install -r requirements.txt
   \`\`\`

3. Run the scanner:
   \`\`\`bash
   python3 main.py
   \`\`\`

4. View the logs in the \`logs/\` directory and the scan reports in the \`reports/\` directory.

## Features

- SQL Injection detection
- Cross-Site Scripting (XSS) detection
- Directory Traversal detection
- Local File Inclusion (LFI) detection
- Customizable payloads
- Detailed logging and reporting

## Contributing

Feel free to submit issues or pull requests to improve this scanner.

## License

This project is licensed under the MIT License.
EOL
}

# Function to create the requirements.txt file
create_requirements_txt() {
    echo "Creating requirements.txt..."
    cat > $BASE_DIR/requirements.txt <<EOL
requests
EOL
}

# Create the entire project structure and files
create_directories
copy_payloads
create_init_py
create_payload_loader
create_request_engine
create_sql_injection_scanner
create_xss_scanner
create_directory_traversal_scanner
create_lfi_scanner
create_main_py
create_readme_md
create_requirements_txt

# Provide completion message
echo "Vulnerability Scanner project structure created successfully at $BASE_DIR"
