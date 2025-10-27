#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
OUTPUT_FILE="v8-moved-inspector.tf"
MODULE_NAME="landing_zone"
# ----------------------

echo "🔍 Scanning Terraform state for ${MODULE_NAME} aws_inspector2* resources..."
read -rp '🏠 Enter home region (e.g., eu-central-1): ' HOME_REGION
if [[ -z "${HOME_REGION:-}" ]]; then
  echo "❌ Home region cannot be empty." >&2
  exit 1
fi

echo "📝 Writing moved blocks to '${OUTPUT_FILE}'"
: >"${OUTPUT_FILE}"

terraform state list | grep -E "^module\.${MODULE_NAME}\.aws_inspector2" | while read -r resource; do
  # Insert .module.inspector["<home-region>"]. right after module.<MODULE_NAME>.
  to_address=$(echo "$resource" | sed -E "s/^module\.${MODULE_NAME}\./module.${MODULE_NAME}.module.inspector[\"${HOME_REGION}\"]./")

  # Special-case rename:
  # module.<MODULE_NAME>.aws_inspector2_enabler.audit_account[0]
  #   -> module.<MODULE_NAME>.module.inspector["<home>"].aws_inspector2_enabler.delegated_admin
  if [[ "$resource" =~ ^module\.${MODULE_NAME}\.aws_inspector2_enabler\.audit_account(\[0\])?$ ]]; then
    to_address=$(echo "$to_address" | sed -E 's/(\.aws_inspector2_enabler)\.audit_account/\1.delegated_admin/')
  fi

  # Remove trailing [0] from the TO address (keep it in FROM)
  to_address=$(echo "$to_address" | sed -E 's/\[0\]$//')

  {
    # Optional comment for clarity on the renamed resource
    if [[ "$resource" =~ ^module\.${MODULE_NAME}\.aws_inspector2_enabler\.audit_account(\[0\])?$ ]]; then
      echo "# rename: audit_account -> delegated_admin"
    fi
    echo "moved {"
    echo "  from = ${resource}"
    echo "  to   = ${to_address}"
    echo "}"
    echo
  } >>"${OUTPUT_FILE}"
done

echo "✅ Done. Moved statements written to '${OUTPUT_FILE}'."
echo "💡 Next: run 'terraform plan' to verify the changes."
