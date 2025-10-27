#!/usr/bin/env bash

set -euo pipefail

# --- Configuration ---
OUTPUT_FILE="v8-moved-guardduty.tf"
MODULE_NAME="landing_zone"
# ----------------------

echo "🔍 Scanning Terraform state for ${MODULE_NAME} aws_guardduty* resources..."
read -rp '🏠 Enter home region (e.g., eu-central-1): ' HOME_REGION
if [[ -z "${HOME_REGION:-}" ]]; then
  echo "❌ Home region cannot be empty." >&2
  exit 1
fi

echo "📝 Writing moved blocks to '${OUTPUT_FILE}'"
: >"${OUTPUT_FILE}"

terraform state list | grep -E "^module\.${MODULE_NAME}\.aws_guardduty" | while read -r resource; do
  # Insert .module.guardduty["<home-region>"]. right after module.<MODULE_NAME>.
  to_address=$(echo "$resource" | sed -E "s/^module\.${MODULE_NAME}\./module.${MODULE_NAME}.module.guardduty[\"${HOME_REGION}\"]./")

  comment=""

  # Special-case rename #1: detector.audit -> delegated_admin
  if [[ "$resource" =~ ^module\.${MODULE_NAME}\.aws_guardduty_detector\.audit(\[0\])?$ ]]; then
    to_address=$(echo "$to_address" | sed -E 's/(\.aws_guardduty_detector)\.audit/\1.delegated_admin/')
    comment="# rename: audit -> delegated_admin"
  fi

  # Special-case rename #2: organization_admin_account.audit -> default
  if [[ "$resource" =~ ^module\.${MODULE_NAME}\.aws_guardduty_organization_admin_account\.audit(\[0\])?$ ]]; then
    to_address=$(echo "$to_address" | sed -E 's/(\.aws_guardduty_organization_admin_account)\.audit/\1.default/')
    comment="# rename: audit -> default"
  fi

  # Remove trailing [0] from the TO address (keep it in FROM)
  to_address=$(echo "$to_address" | sed -E 's/\[0\]$//')

  {
    [[ -n "$comment" ]] && echo "$comment"
    echo "moved {"
    echo "  from = ${resource}"
    echo "  to   = ${to_address}"
    echo "}"
    echo
  } >>"${OUTPUT_FILE}"
done

echo "✅ Done. Moved statements written to '${OUTPUT_FILE}'."
echo "💡 Next: run 'terraform plan' to verify the changes."
