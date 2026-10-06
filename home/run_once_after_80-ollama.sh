#!/usr/bin/env bash
# Ollama via dnf instead of piping the upstream installer (curl|sh) to a
# shell -- it's packaged in Fedora's own repo (ollama-0.12.11-4.fc44,
# confirmed via `dnf info ollama` on 2026-10-06).
set -euo pipefail

sudo dnf install -y ollama
ollama pull qwen3-coder
# Start chatting manually with: ollama run qwen3-coder
