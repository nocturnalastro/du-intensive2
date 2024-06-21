#!/bin/bash

# Define the registry value
REGISTRY="$1"

# Define the input and output file names
INPUT_FILE="templates/deployment.yaml.j2"
OUTPUT_FILE="templates/deployment.yaml"

# Replace the placeholder in the input file and write to the output file
sed "s/{{registry}}/${REGISTRY}/g" "${INPUT_FILE}" > "${OUTPUT_FILE}"

# Confirm the replacement and renaming
echo "Placeholder {{registry}} replaced with ${REGISTRY} and saved to ${OUTPUT_FILE}"
