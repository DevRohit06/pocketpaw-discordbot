# Discord-only PocketPaw bot (supports both openai_agents and claude_agent_sdk)
FROM python:3.12-slim

RUN apt-get update && apt-get install -y --no-install-recommends git curl \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash

# Install pocketpaw with discord and openai-agents extras
RUN pip install --no-cache-dir 'pocketpaw[discord,openai-agents]'

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
