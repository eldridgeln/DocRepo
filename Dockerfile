# Dockerfile for testing prg image (contains ONLY FAKE TEST SECRETS)
# Purpose: seed many common secret patterns for scanners (Trivy/Aqua)
FROM alpine:3.10

LABEL maintainer="security-team@example.com" \
      purpose="aqua-trivy-secret-test" \
      scan_date="2026-02-02"

# Install known vulnerable package (to trigger vuln findings)
RUN apk --no-cache add wget

# Create a vulnerable script that uses the installed package
RUN echo "Using vulnerable wget: $(wget --version 2>/dev/null || echo 'wget-not-found')" > /vulnerable_script.sh

# ────────────────────────────────────────────────────────────────
# SEEDED SECRETS: Fake but realistic credentials in several formats
# These are intentionally obvious test values — do NOT use real credentials.
# ────────────────────────────────────────────────────────────────
# 1) .env style (already in your original)
RUN mkdir -p /app && \
    echo 'API_KEY=sk_live_51NfakeKeyThisIsForTestingOnly1234567890abcdef' > /app/.env.example && \
    echo 'DB_PASSWORD=SuperSecretPass123!@#' >> /app/.env.example && \
    echo 'AWS_SECRET_ACCESS_KEY=AKIAIOSFODNN7EXAMPLE/wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY' >> /app/.env.example

# 2) ENV vars (persisted in image config) — scanners often flag these
ENV AWS_ACCESS_KEY_ID=AKIAFAKEACCESSKEYEXAMPLE \
    AWS_SECRET_KEY=FakeSecretKeyForTestingOnly12345 \
    STRIPE_SECRET=sk_test_FAKE_STRIPE_KEY_FOR_TESTING

# 3) JSON credential file
RUN printf '{\n  "username": "svc-account",\n  "password": "P@ssw0rd!Fake123",\n  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.FAKEPAYLOAD.SIGNATURE"\n}\n' > /app/creds.json

# 4) YAML/kubernetes-style secret manifest
RUN printf 'apiVersion: v1\nkind: Secret\nmetadata:\n  name: demo-secret\ndata:\n  password: U3VwZXJTZWNyZXRQYXNzd29yZA==\n' > /app/secret-k8s.yml

# 5) base64-encoded secret file (scanners that decode base64 should detect)
RUN echo -n 'my-very-secret-value' | base64 > /app/base64_secret.txt

# 6) Fake private key block (BEGIN ... END) — scanners often have rules for these
RUN mkdir -p /root/.ssh && \
    printf '-----BEGIN RSA PRIVATE KEY-----\nMIIBOgIBAAJBAFAKEKEYFAKEKEYFAKEKEYFAKEKEYFAKEKEY\n-----END RSA PRIVATE KEY-----\n' > /root/.ssh/id_rsa && \
    chmod 600 /root/.ssh/id_rsa

# 7) Git credentials / .netrc / pip with basic auth style (your pip example kept)
RUN printf "machine github.com login testuser password fake_github_token_123456\n" > /root/.git-credentials && \
    echo 'machine artifactory.example.com login jfrog_user password jfrog_password_ABC123' > /root/.netrc && \
    echo 'PIP_EXTRA_INDEX_URL=https://test1:passwordhidden@xxxx.jfrog.io/xxx/api/pypi/pypi-local/simple' > /root/.pip.conf

# 8) EICAR TEST STRING for AV-like detection (harmless)
RUN echo 'X5O!P%@AP[4\\PZX54(P^)7CC)7}$EICAR-STANDARD-ANTIVIRUS-TEST-FILE!$H+H*' > /eicar_test.txt && \
    echo 'This is a harmless EICAR test file for scanner validation' >> /eicar_test.txt && \
    mv /eicar_test.txt /tmp/malware_test.com

# 9) Additional file types / encodings to broaden detection surface
RUN echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQFAKE_SSH_KEY_FOR_TESTING' > /app/id_rsa.pub && \
    echo 'GIT_TOKEN=ghp_FAKE_GITHUB_TOKEN_FOR_TEST' >> /app/.env.example

# Make the vulnerable script executable
RUN chmod +x /vulnerable_script.sh

# Expose a port (demo)
EXPOSE 80

# Default command (keeps container minimal)
CMD ["/bin/sh", "/vulnerable_script.sh"]
