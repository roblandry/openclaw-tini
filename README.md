# OpenClaw Tini Wrapper

Temporary wrapper image for OpenClaw until the upstream container includes an init/reaper or the gateway reaps orphaned children when running as PID 1.

The image is intentionally small:

- starts from the upstream OpenClaw image
- adds static `tini`
- wraps the original `docker-entrypoint.sh`
- keeps OpenClaw's original command unchanged

Published image:

```text
ghcr.io/roblandry/openclaw-tini:2026.4.26
```

Once upstream has a built-in fix, this repository can be retired and the OpenClawInstance can go back to `ghcr.io/openclaw/openclaw`.
