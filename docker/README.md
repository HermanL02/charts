# Suitely Chatwoot Image

A 3-line custom image on top of upstream `chatwoot/chatwoot`, adding one Rails
initializer that bridges `CAPTAIN_OPEN_AI_*` config into every OpenAI-wire-
compatible RubyLLM provider slot.

## Why

Chatwoot's `lib/llm/config.rb` only configures `openai_api_key` and
`openai_api_base`. RubyLLM has dedicated provider classes for DeepSeek,
Mistral, Ollama, OpenRouter, Perplexity, and GPUStack — each requires its
own `*_api_key` config slot, even though they all speak OpenAI's wire format.
The result is that pointing Chatwoot at e.g. DeepSeek fails with
`RubyLLM::ConfigurationError: Missing configuration for DeepSeek: deepseek_api_key`
even when the key+endpoint are set correctly.

The initializer in `ruby_llm_openai_compatible_providers.rb` copies
Chatwoot's existing `CAPTAIN_OPEN_AI_*` values into all six provider slots
at boot. No source file is replaced — purely additive.

## Build & push

```bash
cd docker
DOCKER_BUILDKIT=1 docker build \
  --build-arg BASE_TAG=v4.13.0 \
  -t asia-east1-docker.pkg.dev/livesuitely/staysuitely/chatwoot:v4.13.0-suitely.1 .
docker push asia-east1-docker.pkg.dev/livesuitely/staysuitely/chatwoot:v4.13.0-suitely.1
```

## Use

In Devtron Helm values:

```yaml
image:
  repository: asia-east1-docker.pkg.dev/livesuitely/staysuitely/chatwoot
  tag: v4.13.0-suitely.1
  pullPolicy: IfNotPresent
```

## Versioning

`<upstream-tag>-suitely.<n>` — bump `n` for each rebuild against the same
upstream base. Reset to `1` when bumping upstream.

## Maintenance on upstream Chatwoot bump

1. Edit `BASE_TAG` arg above (or pass via `--build-arg`)
2. `docker build` + `docker push` (~2 min)
3. Bump `image.tag` in Devtron values, deploy
