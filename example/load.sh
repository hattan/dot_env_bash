#!/usr/bin/env bash

# imports
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
source "$SCRIPT_DIR/../lib/dot_env.sh"

main() {
    dot_env_load
    if [ "$?" -ne 0 ]; then
        exit 1
    fi
    print
}

print(){
    echo "ARM_SUBSCRIPTION_ID=$ARM_SUBSCRIPTION_ID"
    echo "ARM_AAAAI=$ARM_AAAAID"
    echo "ARM_TENANT_ID=$ARM_TENANT_ID"
    echo "COUNT=$COUNT"
    echo "FOO=$FOO"
}

# main
main