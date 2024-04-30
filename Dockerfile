FROM ubuntu:22.04

RUN dnf install -y \
        buildah \
        skopeo \
        && \
    dnf clean all
