#!/usr/bin/env bash
# Git + GitHub setup (shared by git/linux and git/macos).
#
# Asks for name, email and protocol (ssh/https), writes the global git config,
# prepares the SSH key or the gh credential helper, and registers the key on
# GitHub through gh when needed.
#
# Usage: install.sh <linux|macos> [--dry-run]

set -euo pipefail

OS="${1:-}"
case "$OS" in
  linux|macos) ;;
  *)
    echo "Usage: $0 <linux|macos> [--dry-run]" >&2
    exit 2
    ;;
esac

DRY_RUN=0
case "${2:-}" in
  --dry-run) DRY_RUN=1 ;;
  "") ;;
  *)
    echo "Usage: $0 <linux|macos> [--dry-run]" >&2
    exit 2
    ;;
esac

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

log()   { printf '  %s\n' "$*"; }
head_() { printf '\n==> %s\n' "$*"; }
ok()    { printf '  [ok] %s\n' "$*"; }
skip()  { printf '  [skip] %s\n' "$*"; }
warn()  { printf '  [warn] %s\n' "$*" >&2; }

FAILED=()

run() {
  if (( DRY_RUN )); then
    log "would run: $*"
    return 0
  fi
  "$@"
}

# Asks whether to continue without a failed optional step.
# Without a TTY the answer is always yes (continue).
confirm_continue() {
  local what="$1"
  if (( DRY_RUN )) || [[ ! -t 0 ]]; then
    skip "continuing without $what"
    return 0
  fi
  local answer
  read -r -p "  Continue without $what? [Y/n] " answer || answer="y"
  case "$answer" in
    ""|y|Y|yes|YES) skip "continuing without $what"; return 0 ;;
    *) warn "aborting at your request"; exit 1 ;;
  esac
}

# Asks a yes/no question; defaults to yes without a TTY.
confirm() {
  local question="$1"
  if (( DRY_RUN )) || [[ ! -t 0 ]]; then
    return 0
  fi
  local answer
  read -r -p "  $question [Y/n] " answer || answer="y"
  case "$answer" in
    ""|y|Y|yes|YES) return 0 ;;
    *) return 1 ;;
  esac
}

# Asks for a value. Empty input keeps the fallback (which may be empty).
# Without a TTY the fallback is used; a missing required value aborts instead
# of looping forever.
ask() {
  local prompt="$1" fallback="${2:-}" answer=""
  if (( DRY_RUN )) || [[ ! -t 0 ]]; then
    printf '%s' "$fallback"
    return 0
  fi
  read -r -p "  $prompt" answer || answer=""
  printf '%s' "${answer:-$fallback}"
}

# Non-interactive runs fall back to the current git identity, so --dry-run and
# piped installs stay meaningful. A missing value aborts instead of looping.
require() {
  local what="$1" value="$2"
  if [[ -n "$value" ]]; then
    return 0
  fi
  if [[ ! -t 0 ]] && ! (( DRY_RUN )); then
    warn "$what é obrigatório e não há terminal interativo"
    exit 1
  fi
}

# ---------------------------------------------------------------------------
# Inputs
# ---------------------------------------------------------------------------

(( DRY_RUN )) && echo "DRY RUN: nothing will be changed."
echo "Configuring git for $OS"

head_ "Identidade"
NAME="$(ask 'Nome completo (user.name): ' "$(git config --global user.name || true)")"
while [[ -z "$NAME" && -t 0 ]]; do
  warn "o nome é obrigatório"
  NAME="$(ask 'Nome completo (user.name): ')"
done
require "o nome" "$NAME"

EMAIL="$(ask 'E-mail (user.email): ' "$(git config --global user.email || true)")"
while [[ -z "$EMAIL" && -t 0 ]]; do
  warn "o e-mail é obrigatório"
  EMAIL="$(ask 'E-mail (user.email): ')"
done
require "o e-mail" "$EMAIL"

PROTOCOL="$(ask 'Protocolo para o GitHub — ssh ou https [ssh]: ' ssh)"
PROTOCOL="${PROTOCOL,,}"
while [[ "$PROTOCOL" != ssh && "$PROTOCOL" != https ]]; do
  if [[ ! -t 0 ]]; then
    PROTOCOL=ssh
    break
  fi
  warn "escolha ssh ou https"
  PROTOCOL="$(ask 'Protocolo para o GitHub — ssh ou https [ssh]: ' ssh)"
  PROTOCOL="${PROTOCOL,,}"
done

log "nome:      $NAME"
log "e-mail:    $EMAIL"
log "protocolo: $PROTOCOL"

# ---------------------------------------------------------------------------
# Global git config
# ---------------------------------------------------------------------------

head_ "Configuração global"
if [[ "$(git config --global user.name || true)" == "$NAME" ]]; then
  ok "user.name já configurado"
else
  run git config --global user.name "$NAME"
  log "user.name = $NAME"
fi

if [[ "$(git config --global user.email || true)" == "$EMAIL" ]]; then
  ok "user.email já configurado"
else
  run git config --global user.email "$EMAIL"
  log "user.email = $EMAIL"
fi

# ---------------------------------------------------------------------------
# GitHub CLI
# ---------------------------------------------------------------------------

gh_ready() {
  command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1
}

gh_install_linux() {
  if command -v yay >/dev/null 2>&1 && run yay -S --needed --noconfirm github-cli; then
    log "installed github-cli (yay)"
    return 0
  fi
  if run sudo pacman -S --needed --noconfirm github-cli; then
    log "installed github-cli (pacman)"
    return 0
  fi
  gh_install_release
}

gh_install_macos() {
  local brew=""
  if [[ -x /opt/homebrew/bin/brew ]]; then
    brew=/opt/homebrew/bin/brew
  elif [[ -x /usr/local/bin/brew ]]; then
    brew=/usr/local/bin/brew
  elif command -v brew >/dev/null 2>&1; then
    brew="$(command -v brew)"
  fi
  if [[ -n "$brew" ]] && run "$brew" install gh; then
    log "installed gh (brew)"
    return 0
  fi
  gh_install_release
}

# Fallback: the official prebuilt release, unpacked into ~/.local/bin.
gh_install_release() {
  local arch url
  case "$(uname -m)" in
    x86_64)  arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *)
      warn "arquitetura não suportada para o binário do gh: $(uname -m)"
      return 1
      ;;
  esac
  if [[ "$OS" == linux ]]; then
    url="https://github.com/cli/cli/releases/latest/download/gh_\${version}_linux_${arch}.tar.gz"
  else
    url="https://github.com/cli/cli/releases/latest/download/gh_\${version}_macOS_${arch}.tar.gz"
  fi
  if (( DRY_RUN )); then
    log "would download the gh release ($OS/$arch) into ~/.local/bin"
    return 0
  fi
  local version tmp
  version="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
    | grep -oE '"tag_name": *"v[^"]*"' | head -1 | cut -d'"' -f4 | sed 's/^v//')"
  if [[ -z "$version" ]]; then
    warn "não foi possível descobrir a versão mais recente do gh"
    return 1
  fi
  url="${url/\$\{version\}/$version}"
  tmp="$(mktemp -d)"
  if curl -fsSL "$url" | tar -xz -C "$tmp" && compgen -G "$tmp/gh_*/bin/gh" >/dev/null; then
    mkdir -p "$HOME/.local/bin"
    cp "$tmp"/gh_*/bin/gh "$HOME/.local/bin/gh"
    chmod +x "$HOME/.local/bin/gh"
    log "installed gh $version (release) into ~/.local/bin"
    rm -rf "$tmp"
    return 0
  fi
  rm -rf "$tmp"
  return 1
}

ensure_gh() {
  if command -v gh >/dev/null 2>&1; then
    ok "gh instalado"
    return 0
  fi
  if ! confirm "O gh (GitHub CLI) não está instalado. Instalar?"; then
    skip "gh não instalado"
    return 1
  fi
  if [[ "$OS" == linux ]]; then
    gh_install_linux
  else
    gh_install_macos
  fi || {
    warn "não foi possível instalar o gh"
    FAILED+=("gh")
    confirm_continue "o gh"
    return 1
  }
  return 0
}

ensure_gh_login() {
  if gh auth status >/dev/null 2>&1; then
    ok "gh autenticado"
    return 0
  fi
  if (( DRY_RUN )); then
    log "would run: gh auth login"
    return 0
  fi
  if [[ ! -t 0 ]]; then
    warn "gh não autenticado e sem terminal interativo"
    FAILED+=("gh auth login")
    return 1
  fi
  if gh auth login; then
    ok "gh autenticado"
    return 0
  fi
  warn "gh auth login falhou"
  FAILED+=("gh auth login")
  return 1
}

# ---------------------------------------------------------------------------
# SSH
# ---------------------------------------------------------------------------

# Prints the path of the first usable key in ~/.ssh, if any.
find_ssh_key() {
  local key
  for key in "$HOME"/.ssh/id_ed25519 "$HOME"/.ssh/id_rsa "$HOME"/.ssh/id_ecdsa; do
    [[ -f "$key" ]] && { printf '%s' "$key"; return 0; }
  done
  return 1
}

# Sets SSH_KEY to the key to use, creating one when none exists.
# Uses a global instead of stdout so log lines never leak into the value.
ensure_ssh_key() {
  local key
  SSH_KEY=""
  if key="$(find_ssh_key)"; then
    SSH_KEY="$key"
    ok "chave ssh existente: $SSH_KEY"
    return 0
  fi
  SSH_KEY="$HOME/.ssh/id_ed25519"
  if (( DRY_RUN )); then
    log "would run: ssh-keygen -t ed25519 -C \"$EMAIL\" -f $SSH_KEY -N ''"
    return 0
  fi
  mkdir -p "$HOME/.ssh"
  chmod 700 "$HOME/.ssh"
  if ssh-keygen -t ed25519 -C "$EMAIL" -f "$SSH_KEY" -N ""; then
    log "chave ssh criada: $SSH_KEY"
    return 0
  fi
  warn "não foi possível criar a chave ssh"
  FAILED+=("chave ssh")
  SSH_KEY=""
  return 1
}

register_ssh_key() {
  local key="$1"
  if ! confirm "Enviar a chave $key.pub para o GitHub (gh ssh-key add)?"; then
    skip "chave não registrada no GitHub"
    return 0
  fi
  if (( DRY_RUN )); then
    log "would run: gh ssh-key add $key.pub --title $(hostname)"
    return 0
  fi
  if gh ssh-key list 2>/dev/null | grep -qF "$(cut -d' ' -f2 "$key.pub")"; then
    ok "chave já registrada no GitHub"
    return 0
  fi
  if gh ssh-key add "$key.pub" --title "$(hostname)"; then
    ok "chave registrada no GitHub"
    return 0
  fi
  warn "não foi possível registrar a chave no GitHub"
  FAILED+=("gh ssh-key add")
}

# ---------------------------------------------------------------------------
# Credential helper (https)
# ---------------------------------------------------------------------------

# Sets the helper so git never asks for the password again:
# libsecret on Linux (falls back to a 1h cache), osxkeychain on macOS.
# The gh helper is only a last resort when the native one is unavailable.
configure_credential_helper() {
  local helper="" fallback=""

  case "$OS" in
    linux)
      if command -v git-credential-libsecret >/dev/null 2>&1 || [[ -x /usr/lib/git-core/git-credential-libsecret ]]; then
        helper=libsecret
      fi
      fallback=cache
      ;;
    macos)
      helper=osxkeychain
      ;;
  esac

  if [[ -n "$helper" ]]; then
    run git config --global credential.helper "$helper"
    ok "credential.helper = $helper"
    if [[ -n "$fallback" ]] && [[ "$fallback" != "$helper" ]]; then
      # A second helper is only consulted when the first one has no credential.
      run git config --global --add credential.helper "$fallback"
      log "fallback: credential.helper += $fallback"
    fi
    return 0
  fi

  warn "credential helper nativo não disponível ($OS)"
  if gh_ready || { ensure_gh && ensure_gh_login; }; then
    if run gh auth setup-git; then
      ok "gh configurado como credential helper"
      return 0
    fi
  fi
  warn "configure um credential helper manualmente"
  FAILED+=("credential helper")
}

# ---------------------------------------------------------------------------
# Protocol
# ---------------------------------------------------------------------------

if [[ "$PROTOCOL" == ssh ]]; then
  head_ "SSH"
  if ensure_ssh_key; then
    if gh_ready || { ensure_gh && ensure_gh_login; }; then
      register_ssh_key "$SSH_KEY"
    else
      warn "registre manualmente: gh ssh-key add $SSH_KEY.pub"
    fi
  fi
else
  head_ "HTTPS"
  if confirm "Configurar credential helper para não pedir senha de novo?"; then
    configure_credential_helper
  else
    skip "credential helper não configurado"
  fi
fi

head_ "Done"
if (( ${#FAILED[@]} )); then
  warn "skipped: ${FAILED[*]}"
fi
echo "  git configurado para $NAME <$EMAIL> ($PROTOCOL)"
