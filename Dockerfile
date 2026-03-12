# Discord-only PocketPaw bot with Claude Code CLI
FROM node:22-slim AS node

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code && npm cache clean --force

FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends git \
    && rm -rf /var/lib/apt/lists/*

# Copy Node.js + Claude Code CLI from node stage
COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules
RUN ln -s /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -s /usr/local/lib/node_modules/@anthropic-ai/claude-code/cli.js /usr/local/bin/claude

# Install pocketpaw with discord extra from PyPI
RUN pip install --no-cache-dir 'pocketpaw[discord]'

RUN groupadd --system pocketpaw && \
    useradd --system --gid pocketpaw --create-home pocketpaw && \
    mkdir -p /home/pocketpaw/.pocketpaw && \
    chown -R pocketpaw:pocketpaw /home/pocketpaw

# Copy custom identity
COPY identity/ /home/pocketpaw/.pocketpaw/identity/
RUN chown -R pocketpaw:pocketpaw /home/pocketpaw/.pocketpaw/identity/

USER pocketpaw
WORKDIR /home/pocketpaw

CMD ["pocketpaw", "--discord"]
