# Influwealth Snippets (Termius/CLI)

This folder contains copy/paste friendly snippets for common operations.

## PQC file creation scaffold

Use the `pqc_scaffold_files` function from `snippets.sh` or copy the heredocs directly.

## Devbox bootstrap

- `pqc/bootstrap/pqc-bootstrap.sh` installs Devbox (if missing) and builds `liboqs`.

## Sovereign Mesh build + test (WSL)

```bash
cd ~/workspace/sovereign-mesh
cargo test
```

## VR Meeting Room build + sync

This repo is scaffold-only right now. Add Unity/WebXR build steps when you confirm the toolchain.

```bash
cd ~/workspace/vr-meeting-room
ls -la
```

