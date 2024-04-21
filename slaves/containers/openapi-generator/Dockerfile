# https://hub.docker.com/_/node
FROM --platform=linux/amd64 node:20.11-alpine

# https://www.npmjs.com/package/typescript
ARG TYPESCRIPT_VERSION

# https://www.npmjs.com/package/@openapitools/openapi-generator-cli
ARG OPENAPI_VERSION 

# https://www.npmjs.com/package/openapi-merge-cli
ARG MERGE_TOOL_VERSION

RUN apk add --update --no-cache openjdk11

RUN npm install -g typescript@${TYPESCRIPT_VERSION} @openapitools/openapi-generator-cli@${OPENAPI_VERSION} openapi-merge-cli@${MERGE_TOOL_VERSION}

# docker build \
#   --build-arg TYPESCRIPT_VERSION=5.3.3 \
#   --build-arg OPENAPI_VERSION=2.13.1 \
#   --build-arg MERGE_TOOL_VERSION=1.3.1 \
#    -t eu.gcr.io/org/openapi-generator:latest .
