# Runbook — mlops-platform

## How to restore everything from scratch

If this PC dies or you lose access to WSL2, here's how to recover:

1. Install WSL2 and a clean Ubuntu distro on the new machine.

2. Install the base tools (includes `unzip`, required by the rclone installer):
```bash
   sudo apt update && sudo apt install -y git curl age restic gh unzip
   curl -LO https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64
   sudo install -m 755 sops-v3.13.3.linux.amd64 /usr/local/bin/sops
   rm sops-v3.13.3.linux.amd64
   curl https://rclone.org/install.sh | sudo bash
```

3. Clone the repository (never inside `/mnt/c/...` — move to your Linux home first):
```bash
   cd ~
   gh auth login
   gh repo clone YOUR_USERNAME/mlops-platform
   cd mlops-platform
```

4. Recover the age private key from Bitwarden:
```bash
   mkdir -p ~/.config/sops/age
   nano ~/.config/sops/age/keys.txt   # paste the content saved in Bitwarden
   export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
```

5. Load the credentials:
```bash
   set -a
   source <(sops -d restic.enc.env)
   set +a
```

6. Rebuild the rclone remote by writing the file directly — **do not use `rclone config create`**, it tries to refresh the token and fails without a browser:
```bash
   mkdir -p ~/.config/rclone
   cat > ~/.config/rclone/rclone.conf << EOF
   [cristian-drive]
   type = drive
   client_id = $RCLONE_CONFIG_CRISTIAN_DRIVE_CLIENT_ID
   client_secret = $RCLONE_CONFIG_CRISTIAN_DRIVE_CLIENT_SECRET
   scope = $RCLONE_CONFIG_CRISTIAN_DRIVE_SCOPE
   token = $RCLONE_CONFIG_CRISTIAN_DRIVE_TOKEN
   EOF
```

7. Restore:
```bash
   restic restore latest --target ~/restaurado
```

**Recovery time measured in the 2026-09-12 drill: 20 seconds** (with ~40 KiB of test data — this number will grow with real data over time; repeat the drill every 6 months as noted in Chapter 15).

## Rotating a credential
1. Generate the new value.
2. `sops file.enc.env`, replace the value, save.
3. `git add`, `commit`, `push`.
4. Restart whatever service depends on that value.

## What to do when an alert fires


## Rolling back a model
