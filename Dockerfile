# Use an outdated version of Alpine Linux as the base image (known to trigger vuln findings)
FROM alpine:3.10

# Install the latest version of a package known to have vulnerabilities (e.g., wget)
RUN apk --no-cache add wget

# Create a vulnerable script that uses the installed package
RUN echo "Using vulnerable wget: $(wget --version)" > /vulnerable_script.sh

# ────────────────────────────────────────────────────────────────
# SEEDED SECRET: Fake but realistic credential exposed in plain text
# This should be detected by Trivy secret scanner or Aqua secret detection
# ────────────────────────────────────────────────────────────────
RUN echo 'API_KEY=sk_live_51NfakeKeyThisIsForTestingOnly1234567890abcdef' > /app/.env.example && \
    echo 'DB_PASSWORD=SuperSecretPass123!@#' >> /app/.env.example && \
    echo 'AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE/wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' >> /app/.env.example

# ────────────────────────────────────────────────────────────────
# EICAR TEST STRING: Standard harmless test "virus" for AV/malware scanner testing
# Most real AV detects this as EICAR-Test-File / malware-test
# Aqua SaaS or Trivy-with-Aqua-plugin may flag it depending on config
# ────────────────────────────────────────────────────────────────
RUN echo 'X5O!P%@AP[4\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /eicar_test.txt && \
    echo 'This is a harmless EICAR test file for scanner validation' >> /eicar_test.txt

# Optional: Make the EICAR file look more "suspicious" by naming it like an executable
RUN mv /eicar_test.txt /tmp/malware_test.com

# Set permissions to make the script executable (uncommented now)
RUN chmod +x /vulnerable_script.sh

# Fake JFrog/PyPI credential exposure (as in your original)
RUN echo 'PIP_EXTRA_INDEX_URL=https://test1:passwordhidden@xxxx.jfrog.io/xxx/api/pypi/pypi-local/simple' > /root/.pip.conf

# Expose a port (just for demonstration)
EXPOSE 80

# Command to run the vulnerable script (for demo)
CMD ["/bin/sh", "/vulnerable_script.sh"]
