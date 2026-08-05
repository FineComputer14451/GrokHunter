# GrokHunter install guide

## On this NetHunter chroot

```bash
cd ~/GrokHunter
bash install.sh
source ~/.zshrc   # or open a new session
grokhunter doctor
```

## Auth

```bash
# API key (best for mobile / no browser)
printf 'export XAI_API_KEY=%q\n' "xai-YOUR_KEY" > ~/.grok/secrets.env
chmod 600 ~/.grok/secrets.env

# or interactive
grok
```

## Verify

```bash
grokhunter status
grokhunter doctor
grok --version    # expect ≥ 0.2.93
```

## Update overlay

```bash
cd ~/GrokHunter
git pull   # if tracked
bash install.sh
```

## Update Grok binary only

```bash
grokhunter ensure
# or
grokhunter ensure --force
```

## Uninstall

```bash
bash ~/GrokHunter/uninstall.sh
# destructive:
# bash ~/GrokHunter/uninstall.sh --purge-grok
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `grokhunter: command not found` | `export PATH="$HOME/.local/bin:$HOME/.grok/bin:$PATH"` then re-open shell |
| Auth errors | Check `secrets.env` mode 600 and key validity |
| DNS failures | NetHunter should have `/etc/resolv.conf`; if bare Termux, use GrokTerm instead |
| Old grok | `grokhunter ensure --force` |
| TUI broken colors | Use Termux / NetHunter terminal with truecolor; `export COLORTERM=truecolor` |
