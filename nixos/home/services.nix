{ config, pkgs, lib, ... }:
let
  # openclaw is installed globally via npm/nvm outside the Nix store.
  # The wrapper resolves node from nvm at runtime so the service survives
  # node version bumps without needing a home-manager rebuild.
  openclawWrapper = pkgs.writeShellScript "openclaw-gateway" ''
    export NVM_DIR="$HOME/.nvm"
    # Load nvm and activate the default alias so `node` resolves
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    # Fall back to PATH node if nvm isn't installed
    exec node "$HOME/.nvm/versions/node/$(nvm version default 2>/dev/null)/lib/node_modules/openclaw/dist/index.js" \
         gateway --port 18789 \
      2>/dev/null \
    || exec node "$(npm root -g)/openclaw/dist/index.js" gateway --port 18789
  '';
in
{
  # ── OpenClaw API gateway ───────────────────────────────────────────────
  systemd.user.services.openclaw-gateway = {
    Unit = {
      Description  = "OpenClaw Gateway";
      After        = [ "network-online.target" ];
      Wants        = [ "network-online.target" ];
      StartLimitBurst        = 5;
      StartLimitIntervalSec  = 60;
    };

    Service = {
      ExecStart = toString openclawWrapper;
      Restart   = "always";
      RestartSec = 5;
      RestartPreventExitStatus = 78;
      TimeoutStartSec = 30;
      TimeoutStopSec  = 30;
      SuccessExitStatus = "0 143";
      KillMode = "control-group";

      Environment = [
        "HOME=%h"
        "TMPDIR=/tmp"
        "NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt"
        "OPENCLAW_GATEWAY_PORT=18789"
        "OPENCLAW_SYSTEMD_UNIT=openclaw-gateway.service"
        "OPENCLAW_WINDOWS_TASK_NAME=OpenClaw Gateway"
        "OPENCLAW_SERVICE_MARKER=openclaw"
        "OPENCLAW_SERVICE_KIND=gateway"
      ];
    };

    Install.WantedBy = [ "default.target" ];
  };
}
