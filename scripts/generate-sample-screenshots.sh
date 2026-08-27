#!/usr/bin/env bash
set -Eeuo pipefail

IFS=$'\n\t'

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"

CODE_CMD="${CODE_CMD:-code}"
SPECTACLE_CMD="${SPECTACLE_CMD:-spectacle}"

THEME_LABEL="${THEME_LABEL:-Ergolight Theme}"
SAMPLES_DIR="${SAMPLES_DIR:-${REPO_DIR}/samples}"
SCREENSHOTS_DIR="${SCREENSHOTS_DIR:-${REPO_DIR}/screenshots}"

WAIT_AFTER_OPEN_SECONDS="${WAIT_AFTER_OPEN_SECONDS:-8}"
WAIT_AFTER_FILE_SECONDS="${WAIT_AFTER_FILE_SECONDS:-3}"

TEMP_ROOT="${TEMP_ROOT:-}"
KEEP_PROFILE="${KEEP_PROFILE:-0}"

SOURCE_USER_DATA_DIR="${SOURCE_USER_DATA_DIR:-${HOME}/.config/Code}"
SOURCE_EXTENSIONS_DIR="${SOURCE_EXTENSIONS_DIR:-${HOME}/.vscode/extensions}"

require_command() {
  local command_name="$1"

  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Erro: comando não encontrado: ${command_name}" >&2
    exit 1
  fi
}

sanitize_filename() {
  local relative_path="$1"
  local sanitized="${relative_path//\//__}"

  sanitized="${sanitized// /_}"
  sanitized="${sanitized//:/_}"
  sanitized="${sanitized//\\/__}"

  printf '%s.png' "${sanitized}"
}

focus_vscode_window() {
  if command -v wmctrl >/dev/null 2>&1; then
    wmctrl -a "Visual Studio Code" >/dev/null 2>&1 || true
    wmctrl -a "${THEME_LABEL}" >/dev/null 2>&1 || true
  fi
}

resize_active_window_if_possible() {
  if command -v wmctrl >/dev/null 2>&1; then
    wmctrl -r :ACTIVE: -e 0,80,60,1400,1000 >/dev/null 2>&1 || true
  fi
}

hide_vscode_sidebar() {
  focus_vscode_window
  sleep 0.5
  xdotool key --clearmodifiers ctrl+b
  sleep 0.5
}

capture_active_window() {
  local output_path="$1"

  if "${SPECTACLE_CMD}" -a -b -n -o "${output_path}" >/dev/null 2>&1; then
    return 0
  fi

  "${SPECTACLE_CMD}" -a -b -o "${output_path}"
}

require_command "${CODE_CMD}"
require_command "${SPECTACLE_CMD}"
require_command "npx"
require_command "xdotool"

if [[ ! -d "${SAMPLES_DIR}" ]]; then
  echo "Erro: pasta de samples não encontrada: ${SAMPLES_DIR}" >&2
  exit 1
fi

mapfile -d '' SAMPLE_FILES < <(find "${SAMPLES_DIR}" -type f -print0 | sort -z)

if [[ "${#SAMPLE_FILES[@]}" -eq 0 ]]; then
  echo "Erro: nenhum arquivo encontrado em: ${SAMPLES_DIR}" >&2
  exit 1
fi

if [[ -z "${TEMP_ROOT}" ]]; then
  TEMP_ROOT="$(mktemp -d /tmp/ergolight-vscode.XXXXXX)"
fi

USER_DATA_DIR="${TEMP_ROOT}/user-data"
EXTENSIONS_DIR="${TEMP_ROOT}/extensions"
VSIX_PATH="${TEMP_ROOT}/ergolight-theme.vsix"

if [[ "${KEEP_PROFILE}" != "1" ]]; then
  cleanup() {
    rm -rf -- "${TEMP_ROOT}"
  }

  trap cleanup EXIT
fi

if [[ ! -d "${SOURCE_USER_DATA_DIR}" ]]; then
  echo "Erro: perfil padrão do VS Code não encontrado: ${SOURCE_USER_DATA_DIR}" >&2
  exit 1
fi

if [[ ! -d "${SOURCE_EXTENSIONS_DIR}" ]]; then
  echo "Erro: diretório de extensões do VS Code não encontrado: ${SOURCE_EXTENSIONS_DIR}" >&2
  exit 1
fi

mkdir -p "${USER_DATA_DIR}" "${EXTENSIONS_DIR}" "${SCREENSHOTS_DIR}"

echo "Copiando perfil padrão do VS Code..."
cp -a -- "${SOURCE_USER_DATA_DIR}/." "${USER_DATA_DIR}/"

echo "Copiando extensões instaladas do VS Code..."
cp -a -- "${SOURCE_EXTENSIONS_DIR}/." "${EXTENSIONS_DIR}/"

mkdir -p "${USER_DATA_DIR}/User"

echo "Empacotando tema..."
(
  cd "${REPO_DIR}"
  npx vsce package --no-dependencies --out "${VSIX_PATH}"
)

echo "Aplicando configurações ao perfil temporário do VS Code em: ${USER_DATA_DIR}"
cat > "${USER_DATA_DIR}/User/settings.json" <<JSON
{
  "workbench.colorTheme": "${THEME_LABEL}",
  "workbench.startupEditor": "none",
  "workbench.activityBar.location": "hidden",
  "workbench.statusBar.visible": false,
  "workbench.editor.showTabs": false,
  "workbench.sideBar.location": "left",
  "breadcrumbs.enabled": false,
  "editor.fontFamily": "IBM Plex Mono",
  "editor.fontWeight": 500,
  "editor.fontSize": 18,
  "editor.lineHeight": 0,
  "editor.minimap.enabled": false,
  "editor.renderWhitespace": "none",
  "editor.renderLineHighlight": "none",
  "editor.guides.indentation": false,
  "editor.scrollbar.vertical": "hidden",
  "editor.scrollbar.horizontal": "hidden",
  "editor.semanticHighlighting.enabled": true,
  "editor.renderValidationDecorations": "off",
  "typescript.validate.enable": false,
  "javascript.validate.enable": false,
  "workbench.silentNotifications": true,
  "window.commandCenter": false,
  "window.restoreWindows": "none",
  "security.workspace.trust.enabled": false,
  "extensions.ignoreRecommendations": true,
  "extensions.showRecommendationsOnlyOnDemand": true,
  "chat.disableAIFeatures": true,
  "github.gitAuthentication": false,
  "git.enabled": false,
  "telemetry.telemetryLevel": "off"
}
JSON

echo "Instalando extensão empacotada no perfil temporário..."
"${CODE_CMD}" \
  --user-data-dir "${USER_DATA_DIR}" \
  --extensions-dir "${EXTENSIONS_DIR}" \
  --install-extension "${VSIX_PATH}" \
  --force

echo "Abrindo janela temporária do VS Code..."
"${CODE_CMD}" \
  --user-data-dir "${USER_DATA_DIR}" \
  --extensions-dir "${EXTENSIONS_DIR}" \
  --new-window "${REPO_DIR}" >/dev/null 2>&1 &

sleep "${WAIT_AFTER_OPEN_SECONDS}"
focus_vscode_window
resize_active_window_if_possible
hide_vscode_sidebar

echo "Configure a janela do Visual Studio Code"
read -n 1 -s -r -p "Pressione qualquer tecla para continuar..."

echo "Gerando screenshots em: ${SCREENSHOTS_DIR}"

for sample_file in "${SAMPLE_FILES[@]}"; do
  relative_path="${sample_file#${SAMPLES_DIR}/}"
  output_file="${SCREENSHOTS_DIR}/$(sanitize_filename "${relative_path}")"

  echo "Capturando: ${relative_path}"

  "${CODE_CMD}" \
    --user-data-dir "${USER_DATA_DIR}" \
    --extensions-dir "${EXTENSIONS_DIR}" \
    --reuse-window \
    --goto "${sample_file}:5:10" >/dev/null 2>&1

  sleep "${WAIT_AFTER_FILE_SECONDS}"
  focus_vscode_window
  resize_active_window_if_possible
  capture_active_window "${output_file}"
  sleep 10
done

echo "Concluído."
echo "Screenshots: ${SCREENSHOTS_DIR}"

if [[ "${KEEP_PROFILE}" == "1" ]]; then
  echo "Perfil temporário mantido em: ${TEMP_ROOT}"
fi
