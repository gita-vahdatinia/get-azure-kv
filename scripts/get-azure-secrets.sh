#!/bin/bash
keyVaultName=$1
input="${@:2}"

formatted_input="$(echo "$input" | tr " " "\n" | tr ";" "\n")"

while read -r line; do
    (
        echo "::debug::Reading line: $line"
        if [ -n "$line" ]; then
            envVariableName="${line%=*}"
            secretName="${line#*=}"
            echo "Fetching $secretName from $keyVaultName"
            secretValue=$(az keyvault secret show --name "$secretName" --vault-name "$keyVaultName" --query value --output tsv)
            echo "$envVariableName=$secretValue" >> "$GITHUB_ENV"
        else
            echo "::debug::Line is empty, skipping"
        fi
    ) &
done <<< "$formatted_input"

# waiting background jobs to finish
wait