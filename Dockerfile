ARG OPENCLAW_VERSION=2026.4.26
FROM ghcr.io/openclaw/openclaw:${OPENCLAW_VERSION}

ARG TINI_VERSION=v0.19.0

USER root
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static-amd64 /usr/local/bin/tini
RUN chmod +x /usr/local/bin/tini

USER node
ENTRYPOINT ["/usr/local/bin/tini", "--", "docker-entrypoint.sh"]
CMD ["node", "openclaw.mjs", "gateway", "--allow-unconfigured"]
