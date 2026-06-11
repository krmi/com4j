:: @echo off
setlocal
:: Leitet den API-Traffic auf deinen lokalen llama-server um
set "ANTHROPIC_BASE_URL=http://172.30.0.162:8080"
:: Ein Token muss gesetzt sein, damit Claude Code nicht den offiziellen Cloud-Login triggert.
:: Der genaue String ist für deinen lokalen Server irrelevant.
set "ANTHROPIC_AUTH_TOKEN=lokal"
:: Blockiert den Versuch von Claude Code, im Hintergrund Telemetrie-Traffic zu senden:
set "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1"
set "CLAUDE_CODE_MAX_OUTPUT_TOKENS=16384"
claude --model qwen3.6-27b  %*
::claude --model gemma-4-12b  %*