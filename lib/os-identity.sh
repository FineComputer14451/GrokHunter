#!/usr/bin/env bash
# OS identity for grokhunter doctor.
# Spec: /etc/os-release, fallback /usr/lib/os-release.
# Termux host: $PREFIX/etc/os-release. Missing file is not a lab failure.

_gh_os_release_file() {
  local root="${GROKHUNTER_OS_ROOT:-}" f
  for f in \
    "${root}/etc/os-release" \
    "${root}/usr/lib/os-release" \
    ${PREFIX:+"${PREFIX}/etc/os-release"}
  do
    [[ -r "${f}" ]] || continue
    printf '%s\n' "${f}"
    return 0
  done
  return 1
}
