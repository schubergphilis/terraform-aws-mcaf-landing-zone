#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
OUTPUT_FILE="v9-moved-kms.tf"
MODULE_NAME="landing_zone"
# ----------------------

echo "🔍 Scanning Terraform state for ${MODULE_NAME} module.kms_key* modules..."
read -rp '🏠 Enter home region (e.g., eu-central-1): ' HOME_REGION
if [[ -z "${HOME_REGION:-}" ]]; then
  echo "❌ Home region cannot be empty." >&2
  exit 1
fi

echo "📝 Writing moved blocks to '${OUTPUT_FILE}'"
: >"${OUTPUT_FILE}"

# Collect unique top-level module paths such as:
#   module.landing_zone.module.kms_key
#   module.landing_zone.module.kms_key_audit
#   module.landing_zone.module.kms_key_logging
terraform state list \
  | grep -E "^module\.${MODULE_NAME}\.module\.kms_key[^.]*([.]|$)" \
  | sed -E "s/^(module\.${MODULE_NAME}\.module\.[^\.]+).*$/\1/" \
  | sort -u \
  | while IFS= read -r from_module; do
      to_module="${from_module}[\"${HOME_REGION}\"]"
      {
        echo "moved {"
        echo "  from = ${from_module}"
        echo "  to   = ${to_module}"
        echo "}"
        echo
      } >>"${OUTPUT_FILE}"
    done

echo "✅ Done. Moved statements written to '${OUTPUT_FILE}'."
echo "💡 Next: run 'terraform plan' to verify the changes."
