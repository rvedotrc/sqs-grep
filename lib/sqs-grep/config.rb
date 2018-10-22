module SqsGrep

  class Config
    # Stronger builder pattern would be nice
    attr_accessor :client_options, :sqs_client,
      :pattern, :queue_name,
      :send_to,
      :invoke_lambda,
      :lambda_client,
      :visibility_timeout,
      :wait_time_seconds,
      :max_count,
      :delete_matched,
      :invert_match,
      :output_format

    def initialize
      @client_options = {}
      @send_to = nil
      @invoke_lambda = nil
      @lambda_client = nil
      @visibility_timeout = 30
      @wait_time_seconds = 10
      @max_count = nil
      @delete_matched = false
      @invert_match = false
      @output_format = :plain
    end

    def json
      @output_format = :json
    end

    def count
      @output_format = :count
    end

    def validate
      if !@pattern
        raise "Missing pattern"
      end
      if !@queue_name
        raise "Missing queue name"
      end
    end
  end

end
