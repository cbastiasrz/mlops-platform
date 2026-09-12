# Runbook — mlops-platform

## Cómo restaurar todo desde cero

Si esta PC muere o pierdes acceso a WSL2, así se recupera:

1. Instala WSL2 y una distro Ubuntu limpia en la máquina nueva.
2. Instala las herramientas base:
```bash
   sudo apt update && sudo apt install -y git curl age restic gh
   curl -LsSf https://astral.sh/uv/install.sh | sh
   curl -LO https://github.com/getsops/sops/releases/download/v3.13.3/sops-v3.13.3.linux.amd64
   sudo install -m 755 sops-v3.13.3.linux.amd64 /usr/local/bin/sops
   curl https://rclone.org/install.sh | sudo bash
```
3. Clona el repositorio:
```bash
   gh auth login
   gh repo clone TU_USUARIO/mlops-platform
```
4. Recupera la clave privada de age desde Bitwarden:
```bash
   mkdir -p ~/.config/sops/age
   nano ~/.config/sops/age/keys.txt   # pega el contenido guardado en Bitwarden
   export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
```
5. Carga las credenciales y restaura los datos:
```bash
   cd mlops-platform
   set -a; source <(sops -d restic.enc.env); set +a
   time restic restore latest --target ~/restaurado
```

## Rotar una credencial
1. Genera el nuevo valor.
2. `sops archivo.enc.env`, reemplaza el valor, guarda.
3. `git add`, `commit`, `push`.
4. Reinicia el servicio que dependa de ese valor.

## Rollback de un modelo
Por completar

## Qué hacer si suena una alerta
Por completar