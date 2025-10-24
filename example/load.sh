#!/usr/bin/env bash

# imports
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
# shellcheck source=../lib/dot_env.sh
# shellcheck disable=SC1091
source "$SCRIPT_DIR/../lib/dot_env.sh"

main() {
    if ! dot_env_load; then
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
    echo "DEBUG=$DEBUG"
}

# main
main