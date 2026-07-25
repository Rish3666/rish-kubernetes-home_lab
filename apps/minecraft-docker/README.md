# Minecraft Fabric + playit on Docker

This folder contains the Docker Compose stack for the Minecraft server and a small helper to start the playit agent from a terminal on the host.

## Fresh playit setup

1. Install playit on the host using the official Linux instructions: https://playit.gg/support/run-on-linux/
2. Run the agent from this folder:

```bash
cd /home/rishlab/rishlab/apps/minecraft-docker
./playit-start.sh
```

3. In the playit dashboard, create a new tunnel with these values:

```text
Type: Minecraft Java
Local host: 127.0.0.1
Local port: 25565
```

4. Start the server:

```bash
cd /home/rishlab/rishlab/apps/minecraft-docker
./deploy.sh
```

Or use the shortcuts:

```bash
./start.sh
./stop.sh
./restart.sh
```

`./start.sh` starts an existing container, `./stop.sh` stops it, and `./restart.sh` restarts it.
Use `./deploy.sh` the first time, or when the compose file changes.

In a second terminal, watch status:

```bash
cd /home/rishlab/rishlab/apps/minecraft-docker
./status.sh
```

## Why port 25565

Docker publishes the Minecraft server directly on the host at `25565`, so playit can forward to `127.0.0.1:25565`.

## Auto-start playit

If you want the playit agent to start on boot, install the service file from `rishlab/scripts/playit.service`:

```bash
sudo cp /home/rishlab/rishlab/scripts/playit.service /etc/systemd/system/playit.service
sudo systemctl daemon-reload
sudo systemctl enable --now playit.service
```

The unit runs as the `rishlab` user, so it matches the account you are already using on this host.

## Manual server control

The Minecraft server should stay stopped until you start it manually.

After that:

```bash
./start.sh
./stop.sh
./restart.sh
```

These only control the running Docker container. They do not redeploy the stack unless you run `./deploy.sh`.
