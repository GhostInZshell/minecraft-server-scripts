# Minecraft Server Scripts

This repository contains scripts used to manage my Paper Minecraft server hosted on a DigitalOcean droplet running Ubuntu 24.04.3 LTS.

## Scripts

- `start_tmux_server.sh` – Starts the server in a tmux session with auto-restart on crash
- `backup.sh` – Backs up the server world using Duplicity
- `restore_paper.sh` – Provides a dry-run restore menu for backups
- `join_notifier.sh` – Sends Discord notifications when players join
- `monitor.sh` – Logs resource usage for monitoring
- `start.sh` – Starts the paper *.jar server (placed in ~/paper_minecraft)
- `graceful_restart.sh` – Sends timed in-game restart warnings and gracefully stops the server
- `plugin_versions.sh` – Gets paper jar version and plugin versions (useful for plugin upgrades)

## Notes

- Server files (including start.sh) are stored in `~/paper_minecraft`
- All other scripts are placed in /home directory (~)
- Backups are stored in `~/paper_backups_duplicity`
- Logs are saved to `server-restarts.log`
- Designed for small servers (1–5 players) on 2 vCPU / 4GB RAM
