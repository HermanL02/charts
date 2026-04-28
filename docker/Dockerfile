# syntax=docker/dockerfile:1.6
ARG BASE_TAG=v4.13.0
FROM chatwoot/chatwoot:${BASE_TAG}

# Drop a Rails initializer that mirrors Chatwoot's CAPTAIN_OPEN_AI_* config
# into every OpenAI-wire-compatible RubyLLM provider slot, so models routed
# to those providers (deepseek, mistral, ollama, openrouter, perplexity,
# gpustack) can use the same key/endpoint Chatwoot already exposes through
# the super_admin UI.
COPY ruby_llm_openai_compatible_providers.rb /app/config/initializers/

# Sanity check at build time.
RUN test -f /app/config/initializers/ruby_llm_openai_compatible_providers.rb
