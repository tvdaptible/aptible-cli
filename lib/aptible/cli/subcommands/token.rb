module Aptible
  module CLI
    module Subcommands
      module Token
        VALID_SCOPES = %w(read manage).freeze
        def self.included(thor)
          thor.class_eval do
            include Helpers::Token
            include Helpers::Telemetry

            desc "token:create [--scope #{VALID_SCOPES.join('|')}] " \
                 '[--lifetime DURATION]',
                 'Create a new API token'
            option :lifetime, desc: 'The duration the token should be valid ' \
                                    'for (example usage: 24h, 1d, 600s, etc.)'
            option :scope, desc: 'The scope of the token default: read ' \
                                 "(options: #{VALID_SCOPES.join(', ')})"
            define_method 'token:create' do
              telemetry(__method__, options)
              duration = ChronicDuration.parse(options[:lifetime] || '30d')
              if duration.nil?
                raise Thor::Error,
                      "Invalid token lifetime requested: #{lifetime}"
              end
              scope = options[:scope] || 'read'
              unless VALID_SCOPES.include?(scope.downcase)
                raise Thor::Error,
                      "Invalid token scope '#{scope}', must be one of " \
                      "#{VALID_SCOPES}"
              end
              token_options = {
                user_token: fetch_token,
                token: fetch_token,
                scope: scope,
                expires_in: duration
              }
              token = Aptible::Auth::Token.create(token_options)
              Formatter.render(Renderer.current) do |root|
                if Renderer.format == 'json'
                  root.object do |o|
                    o.value('token', token.token)
                  end
                else
                  root.value token.token
                end
              end
            end
          end
        end
      end
    end
  end
end
