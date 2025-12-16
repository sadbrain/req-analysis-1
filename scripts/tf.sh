#!/usr/bin/env bash
set -euo pipefail

ENV="${ENV:-dev}"
CMD="${1:-plan}"
shift || true

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_DIR="${ROOT_DIR}/env/${ENV}"
AUTO_FILE="${ROOT_DIR}/terraform.auto.tfvars"

if [[ ! -d "${ENV_DIR}" ]]; then
  echo "❌ env folder not found: ${ENV_DIR}"
  exit 1
fi

cleanup() { rm -f "${AUTO_FILE}"; }
trap cleanup EXIT

# Gộp toàn bộ *.tfvars trong env/<env>/ thành 1 file auto ở root
# (remote backend chỉ “chấp nhận” kiểu auto tfvars, không chấp nhận -var-file) :contentReference[oaicite:1]{index=1}
: > "${AUTO_FILE}"
for f in "${ENV_DIR}"/*.tfvars; do
  [[ -f "$f" ]] || continue
  echo -e "\n# ===== from ${f##*/} =====\n" >> "${AUTO_FILE}"
  cat "$f" >> "${AUTO_FILE}"
done

# init theo backend.hcl nếu có
if [[ "${CMD}" == "init" ]]; then
  if [[ -f "${ENV_DIR}/backend.hcl" ]]; then
    terraform -chdir="${ROOT_DIR}" init -reconfigure -backend-config="${ENV_DIR}/backend.hcl" "$@"
  else
    terraform -chdir="${ROOT_DIR}" init -reconfigure "$@"
  fi
  exit 0
fi

terraform -chdir="${ROOT_DIR}" "${CMD}" "$@"
