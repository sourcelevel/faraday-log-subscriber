module Faraday
  module ControllerRuntime
    extend ActiveSupport::Concern

    protected

    def append_info_to_payload(payload)
      super
      payload[:faraday_runtime] = Faraday::LogSubscriber.runtime
    end

    module ClassMethods
      def log_process_action(payload)
        messages, runtime = super, payload[:faraday_runtime]
        messages << ('Faraday: %.1fms' % runtime.to_f) if runtime
        messages
      end
    end
  end
end

ActiveSupport.on_load(:action_controller) do
  include Faraday::ControllerRuntime
end
