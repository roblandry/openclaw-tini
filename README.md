# OpenClaw Tini Wrapper

Temporary wrapper image for OpenClaw until the upstream container includes an init/reaper or the gateway reaps orphaned children when running as PID 1.

## Why This Exists

OpenClaw's upstream container currently starts the gateway process directly as PID 1 in Kubernetes:

```text
PID   PPID STAT COMMAND          COMMAND
1     0    Ssl  openclaw-gateway openclaw-gateway
```

When QMD memory, Git, shell helpers, or other subprocesses exit, some orphaned child processes can remain as zombies under PID 1:

```text
[qmd] <defunct>
[git] <defunct>
[sh] <defunct>
```

That is a container PID 1/reaping problem. Normal application processes do not automatically behave like an init process, and if PID 1 does not reap inherited children, defunct processes can accumulate over time.

This became visible while running OpenClaw with:

- the OpenClaw Kubernetes operator
- QMD memory enabled
- session export and memory indexing active
- long-running HomeOps workloads

## Failed Workarounds

We first tried a Kyverno mutate-existing policy to patch the operator-generated StatefulSet and wrap the gateway with Tini. That caused Kyverno and the OpenClaw operator to fight over the same StatefulSet, which led to repeated pod recreation.

We also tried installing an `openclaw-gateway` wrapper earlier in `PATH` from an init container. That did not work because the image starts via its configured entrypoint/CMD rather than resolving `openclaw-gateway` through `PATH`.

## What This Image Does

The image is intentionally small:

- starts from the upstream OpenClaw image
- adds static `tini`
- wraps the original `docker-entrypoint.sh`
- keeps OpenClaw's original command unchanged

In effect:

```dockerfile
ENTRYPOINT ["/usr/local/bin/tini", "--", "docker-entrypoint.sh"]
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
```

Published image:

```text
ghcr.io/roblandry/openclaw-tini:2026.4.26
```

## Retirement Plan

This is a workaround, not a fork of OpenClaw. Once upstream either:

- adds Tini/dumb-init to the official image,
- makes the gateway reap orphaned children correctly when running as PID 1, or
- adds an operator-supported entrypoint wrapper option,

this repository can be retired and the OpenClawInstance can go back to `ghcr.io/openclaw/openclaw`.
