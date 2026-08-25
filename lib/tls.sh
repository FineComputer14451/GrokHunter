#!/usr/bin/env bash
# Termux/Grok inject SSL_CERT_FILE=/etc/tls/cert.pem (often missing in Kali).
# One policy: rewrite to the Kali CA when the injected path is unusable.

_gh_tls_kali_ca_file() {
  if [[ -r /etc/ssl/certs/ca-certificates.crt ]]; then
    printf '%s\n' /etc/ssl/certs/ca-certificates.crt
    return 0
  fi
  return 1
}

_gh_tls_kali_ca_dir() {
  if [[ -d /etc/ssl/certs ]]; then
    printf '%s\n' /etc/ssl/certs
    return 0
  fi
  return 1
}

_gh_tls_sanitize_env() {
  local ca
  if [[ -n "${SSL_CERT_FILE:-}" && ! -r "${SSL_CERT_FILE}" ]]; then
    if ca="$(_gh_tls_kali_ca_file)"; then
      export SSL_CERT_FILE="${ca}"
    else
      unset SSL_CERT_FILE
    fi
  fi
  if [[ -n "${SSL_CERT_DIR:-}" && ! -d "${SSL_CERT_DIR}" ]]; then
    if ca="$(_gh_tls_kali_ca_dir)"; then
      export SSL_CERT_DIR="${ca}"
    else
      unset SSL_CERT_DIR
    fi
  fi
}

_gh_kali_rootfs() {
  printf '%s\n' "${DEFAULT_ROOTFS_DIR:-${NH_ROOTFS:-${TERMUX_FILES_DIR:-/data/data/com.termux/files}/kali}}"
}

# Write /etc/tls into the Kali rootfs (install_cli_bins on Termux sees host
# /etc/tls/cert.pem and would skip a live /etc check). Also try live /etc
# when running inside Kali.
_gh_install_tls_compat() {
  local root dest_tls
  root="$(_gh_kali_rootfs)"
  dest_tls="${root}/etc/tls"
  if [[ -d "${root}" && -r "${root}/etc/ssl/certs/ca-certificates.crt" && ! -e "${dest_tls}/cert.pem" ]]; then
    mkdir -p "${dest_tls}" 2>/dev/null || true
    ln -sfn /etc/ssl/certs "${dest_tls}/certs" 2>/dev/null || true
    ln -sf /etc/ssl/certs/ca-certificates.crt "${dest_tls}/cert.pem" 2>/dev/null || true
  fi
  if [[ ! -e /etc/tls/cert.pem && -r /etc/ssl/certs/ca-certificates.crt ]]; then
    if command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
      sudo -n mkdir -p /etc/tls 2>/dev/null || true
      sudo -n ln -sfn /etc/ssl/certs /etc/tls/certs 2>/dev/null || true
      sudo -n ln -sf /etc/ssl/certs/ca-certificates.crt /etc/tls/cert.pem 2>/dev/null || true
    fi
  fi
}
