# GrokHunter bash completion
# Installed via: bash scripts/install-completions.sh

_grokhunter_completions() {
  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  prev="${COMP_WORDS[COMP_CWORD-1]}"

  local cmds="status doctor binds proot-binds setup sync boot ensure models skills agents team coding-team scout benjamin lucas harper review fix desktop overlay ship docs modeler ci aider session host mcp plugin flow storage editor hook shell github secrets toolchain tls net menu git-identity credits ai-smoke smoke install plan help version"
  local model_sub="install status force --force help"
  local skills_sub="install status help"
  local agents_sub="status list help"
  local identity_sub="show set help --name --email --local --global"
  local binds_sub="status show repair optimize help"
  local setup_opts="--force-grok --with-models --with-aider --no-doctor --yes --help"
  local install_opts="--full --mini --nano --de --browser --no-de --with-grok --no-grok --with-x11 --no-x11 --with-aider --no-aider --with-v9-models --no-v9-models --with-completions --no-completions --overlay-only --help"

  if [[ ${COMP_CWORD} -eq 1 ]]; then
    COMPREPLY=( $(compgen -W "${cmds} -p --prompt --" -- "${cur}") )
    return 0
  fi

  case "${COMP_WORDS[1]}" in
    models)
      COMPREPLY=( $(compgen -W "${model_sub}" -- "${cur}") )
      ;;
    skills)
      COMPREPLY=( $(compgen -W "${skills_sub}" -- "${cur}") )
      ;;
    agents)
      COMPREPLY=( $(compgen -W "${agents_sub}" -- "${cur}") )
      ;;
    git-identity|git_identity|identity)
      COMPREPLY=( $(compgen -W "${identity_sub}" -- "${cur}") )
      ;;
    binds|proot-binds)
      COMPREPLY=( $(compgen -W "${binds_sub}" -- "${cur}") )
      ;;
    setup|sync|boot)
      COMPREPLY=( $(compgen -W "${setup_opts}" -- "${cur}") )
      ;;
    install)
      if [[ "${prev}" == "--de" ]]; then
        COMPREPLY=( $(compgen -W "xfce mate lxde kde gnome i3 e17" -- "${cur}") )
      elif [[ "${prev}" == "--browser" ]]; then
        COMPREPLY=( $(compgen -W "chromium firefox both" -- "${cur}") )
      else
        COMPREPLY=( $(compgen -W "${install_opts}" -- "${cur}") )
      fi
      ;;
    ensure)
      COMPREPLY=( $(compgen -W "--force" -- "${cur}") )
      ;;
    ai-smoke|smoke|team|coding-team|scout|benjamin|lucas|harper|review|fix|desktop|plan)
      # free-form prompt
      ;;
  esac
}

complete -F _grokhunter_completions grokhunter
