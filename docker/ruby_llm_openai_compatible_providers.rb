# Bridge Chatwoot's CAPTAIN_OPEN_AI_* InstallationConfig values into every
# RubyLLM provider that speaks the OpenAI wire format. This lets the existing
# Chatwoot config screen drive any OpenAI-compatible gateway (DeepSeek,
# Mistral, Ollama, OpenRouter, Perplexity, GPUStack), not only OpenAI itself.
#
# Without this, RubyLLM looks up the model name → sees provider="deepseek"
# (or similar) → tries to use deepseek_api_key (which Chatwoot does not set)
# and the call fails with RubyLLM::ConfigurationError.

Rails.application.config.after_initialize do
  next unless ActiveRecord::Base.connection.data_source_exists?('installation_configs')

  api_key  = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_API_KEY')&.value
  api_base = InstallationConfig.find_by(name: 'CAPTAIN_OPEN_AI_ENDPOINT')&.value&.chomp('/')
  next if api_key.blank?

  Llm::Config.initialize! if defined?(Llm::Config)

  # Not every provider exposes a *_api_base setter — some (e.g. DeepSeek,
  # Perplexity) hardcode the URL in their provider class. Skip the setter when
  # it doesn't exist; the provider's default base will still resolve correctly.
  RubyLLM.configure do |config|
    %i[deepseek mistral perplexity openrouter ollama gpustack].each do |provider|
      key_setter  = :"#{provider}_api_key="
      base_setter = :"#{provider}_api_base="
      config.public_send(key_setter,  api_key)  if config.respond_to?(key_setter)
      config.public_send(base_setter, api_base) if api_base.present? && config.respond_to?(base_setter)
    end
  end
rescue ActiveRecord::ConnectionNotEstablished, ActiveRecord::StatementInvalid => e
  Rails.logger.warn("ruby_llm_openai_compatible_providers: DB not ready at boot: #{e.message}")
end
