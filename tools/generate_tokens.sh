#!/bin/bash

# Generate Dart models from tokens.json using quicktype only if source files changed

SOURCE1="tokeninfo/tokens.json"
SOURCE2="tokeninfo/tokeninfo_schema.json"
OUTPUT_FILE="lib/tokeninfo/token_model.g.dart"

# Function to check if rebuild is needed
# Returns 1 if rebuild needed, 0 if not
check_rebuild() {
    # Check if output exists
    if [ ! -f "$OUTPUT_FILE" ]; then
        return 1
    fi

    # Check if tokens.json is newer than output
    if [ "$SOURCE1" -nt "$OUTPUT_FILE" ]; then
        return 1
    fi

    # Check if schema is newer than output
    if [ "$SOURCE2" -nt "$OUTPUT_FILE" ]; then
        return 1
    fi

    echo "Token models are up to date"
    return 0
}

# Function to build tokens
# Returns 0 on success, 1 on failure
build_tokens() {
    echo "Generating token models..."

    # Create output directory if it doesn't exist
    mkdir -p lib/tokeninfo

    # Run quicktype to generate Dart models
    quicktype \
      --lang dart \
      --src tokeninfo/tokeninfo_schema.json \
      --src-lang schema \
      --out "$OUTPUT_FILE" \
      --no-date-times \
      --all-properties-optional \
      --null-safety \
      --required-props \
      --coders-in-class \
      --no-enums \
      --top-level SuperGeniusTokenInfo

    if [ $? -eq 0 ]; then
        echo "Token models generated successfully!"
        return 0
    else
        echo "Failed to generate token models!"
        return 1
    fi
}

# Main execution
check_rebuild
if [ $? -eq 1 ]; then
    build_tokens
    if [ $? -ne 0 ]; then
        exit 1
    fi
fi

exit 0
