# Minecraft Server Scripts

This repository contains scripts used to manage my Paper Minecraft server hosted on a DigitalOcean droplet running Ubuntu.

## Scripts

- `start_tmux_server.sh` – Starts the server in a tmux session with auto-restart on crash
- `paper_backup.sh` – Backs up the server world using Duplicity
- `restore_paper.sh` – Provides a dry-run restore menu for backups
- `join_notifier.sh` – Sends Discord notifications when players join
- `monitor_minecraft.sh` – Logs resource usage for monitoring

## Notes

- Backups are stored in `$HOME/paper_backups_duplicity`
- Logs are saved to `server-restarts.log`
- Designed for small servers (1–5 players) on 2 vCPU / 4GB RAM
