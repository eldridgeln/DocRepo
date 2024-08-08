# Use an outdated version of Alpine Linux as the base image
FROM alpine:3.10

# Install the latest version of a package known to have vulnerabilities (e.g., wget)
RUN apk --no-cache add wget

# Create a vulnerable script that uses the installed package
RUN echo "Using vulnerable wget: $(wget --version)" > /vulnerable_script.sh

# Set permissions to make the script executable
RUN chmod +x /vulnerable_script.sh
RUN PIP_EXTRA_INDEX_URL=https://test1:passwordhidden@xxxx.jfrog.io/xxx/api/pypi/pypi-local/simple

# Expose a port (just for demonstration, not necessarily related to the vulnerability)
EXPOSE 80

# Command to run the vulnerable script (again, just for demonstration)
CMD ["/bin/sh", "/vulnerable_script.sh"]
