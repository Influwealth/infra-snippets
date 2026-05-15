#!/usr/bin/env bash
set -euo pipefail

# Influwealth snippets (Termius-friendly)

## PQC scaffold (matching sovereign-mesh/pqc)
function pqc_scaffold_files() {
  mkdir -p pqc/bootstrap pqc/devbox pqc/capsule pqc/agents

  tee pqc/devbox/devbox.json << 'EOF'
{
  "packages": [
    "openssl@3",
    "rustup",
    "python3",
    "python3-pip",
    "cmake",
    "ninja",
    "git"
  ],
  "env": {
    "RUSTFLAGS": "-C target-feature=+crt-static"
  },
  "shell": {
    "init_hook": [
      "echo 'PQC Devbox Environment Loaded'",
      "rustup target add wasm32-unknown-unknown",
      "pip install fastapi uvicorn"
    ]
  }
}
EOF

  tee pqc/bootstrap/pqc-bootstrap.sh << 'EOF'
#!/usr/bin/env bash
set -e

echo "Installing PQC Runtime..."

if ! command -v devbox &> /dev/null; then
  curl -fsSL https://get.jetpack.io/devbox | bash
fi

cd "$(dirname "$0")/../devbox"
devbox shell -- echo "PQC environment ready."

echo "Installing liboqs..."
git clone https://github.com/open-quantum-safe/liboqs.git || true
cd liboqs
mkdir -p build && cd build
cmake -GNinja -DOQS_USE_OPENSSL=ON ..
ninja
sudo ninja install

echo "PQC Bootstrap Complete."
EOF

  chmod +x pqc/bootstrap/pqc-bootstrap.sh

  tee pqc/capsule/capsule.toml << 'EOF'
[capsule]
id = "capsule.pqc_email_shield.v1"
name = "PQC Email Shield"
version = "0.1.0"
description = "Post-quantum cryptography wrapper for email, messaging, and API traffic."
authors = ["Influwealth"]
runtime = "sovereign-mesh-runtime"
backend = "sovereign-mesh-runtime"
wasm_target = "wasm32-unknown-unknown"
wasm_module = "pqc_email_shield.wasm"

[entrypoints]
updates = ["encrypt", "decrypt", "sign", "verify"]
queries = []
update_dispatcher = "capsule_update_entry"

[state]
schema = "pqc-email-shield-state-v1"
mutable = true
retention = "sovereign-security-retain"
stable = true
ephemeral = false
sealed = true

[governance]
capsule_class = "security"
review_required = true
jurisdiction = "sovereign"
upgrade_policy = "governance-approved"

[quantum]
enabled = true
provider = "pqc"
model = "mlkem+mldsa"
deterministic_required = true
EOF

  tee pqc/capsule/policy.yaml << 'EOF'
allow:
  - "encrypt"
  - "decrypt"
  - "sign"
  - "verify"

deny:
  - "export_private_key"

audit:
  level: "full"
EOF

  tee pqc/capsule/graph.yaml << 'EOF'
nodes:
  - id: pqc_runtime
    type: module
  - id: email_wrapper
    type: service

edges:
  - from: pqc_runtime
    to: email_wrapper
    relation: "provides_encryption"
EOF

  tee pqc/capsule/audit.toml << 'EOF'
[audit]
enabled = true
log_level = "info"
record_signatures = true
record_keygen = true
EOF
}

## Sovereign Mesh build/test (WSL)
function sovereign_mesh_build() {
  cd "$HOME/workspace/sovereign-mesh"
  cargo test
}

## VR Meeting Room build/sync (placeholder)
function vr_meeting_room_sync() {
  cd "$HOME/workspace/vr-meeting-room"
  ls -la
}

