module SqsGrep

  class Client

    def self.configure
      Aws.config.merge! core_v2_options
    end

    def self.core_v2_options
      {
	http_proxy: get_proxy,
	user_agent_suffix: "sqs-grep #{VERSION}",
	# http_wire_trace: true,
      }
    end

    def self.get_proxy
      e = ENV['https_proxy']
      e = "https://#{e}" if e && !e.empty? && !e.start_with?('http')
      return e
    end

  end
  
end
