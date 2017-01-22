FROM ubuntu

# Add binary and Dockerfile
COPY Dockerfile /

# Metadata params
ARG BUILD_DATE
ARG VERSION
ARG VCS_URL
ARG VCS_REF

# Metadata
LABEL org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name="WIP" \
      org.label-schema.description="Work in Progress (WIP)" \
      org.label-schema.url="https://github.com/aculich/wip-docker-stacks" \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="myself" \
      org.label-schema.version=$VERSION \
      org.label-schema.schema-version="1.0" \
      com.wip.docker.dockerfile="/Dockerfile" \
      com.wip.license="Apache-2.0"
