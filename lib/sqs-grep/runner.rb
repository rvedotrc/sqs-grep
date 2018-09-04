require 'aws-sdk-sqs'
require 'aws-sdk-lambda'
require 'json'
require 'set'

module SqsGrep

  class Runner

    def initialize(config)
      @config = config

      @config.sqs_client ||= begin
                               effective_options = SqsGrep::Client.core_v2_options.merge(config.client_options)
                               Aws::SQS::Client.new(effective_options)
                             end

      if @config.invoke_lambda
        @config.lambda_client ||= begin
                                    effective_options = SqsGrep::Client.core_v2_options.merge(config.client_options)
                                    Aws::Lambda::Client.new(effective_options)
                                  end
      end
    end

    # Sets $stdout.sync
    def run
      queue_name = @config.queue_name
      queue_url = resolve_queue queue_name
      function_name = @config.invoke_lambda

      send_to_url = if @config.send_to
                      resolve_queue @config.send_to
                    end

      $stdout.sync = true

      seen_message_ids = Set.new
      num_matched = 0

      loop do
        r = @config.sqs_client.receive_message(
          queue_url: queue_url,
          attribute_names: %w[ All ],
          max_number_of_messages: 10,
          visibility_timeout: @config.visibility_timeout,
          wait_time_seconds: @config.wait_time_seconds,
        )

        break if r.messages.empty?

        r.messages.each do |m|
          # puts "%s\t%s\t%s" % [ queue_name, m.message_id, m.receipt_handle ]

          if seen_message_ids.include? m.message_id
            $stderr.puts "Already seen message #{m.message_id} - bailing out in case we're looping"
            return 0
          end
          seen_message_ids << m.message_id

          matches = (m.body.match(@config.pattern) != nil)

          if matches ^ @config.invert_match
            json_data = {
              queue_url: queue_url,
              queue_name: queue_name,
              message_id: m.message_id,
              attributes: m.attributes.to_h,
              body: m.body,
            }
            if !@config.json_format
              puts "%s\t%s" % [ queue_name, m.message_id ]
              puts m.attributes.inspect
              puts m.body
              puts ""
            end

            if send_to_url
              # FIXME? discards message attributes
              send_res = @config.sqs_client.send_message(
                queue_url: send_to_url,
                message_body: m.body,
              )
              if !@config.json_format
                p send_res
                puts ""
              end
            end

            if function_name
              send_res = @config.lambda_client.invoke(
                function_name: function_name,
                invocation_type: 'Event',
                payload: m.body
              )
              if !@config.json_format
                p send_res
                puts ""
              end
            end

            if @config.delete_matched
              delete_res = @config.sqs_client.delete_message(
                queue_url: queue_url,
                receipt_handle: m.receipt_handle,
              )
              if !@config.json_format
                p delete_res
                puts ""
              end
            end

            if @config.json_format
              puts JSON.pretty_generate(json_data)
            end

            num_matched = num_matched + 1
            return 0 if @config.max_count and num_matched >= @config.max_count
          end
        end
      end

      return 0
    end

    private

    def resolve_queue(queue_name)
      @config.sqs_client.list_queues(queue_name_prefix: queue_name).queue_urls.find {|url| File.basename(url) == queue_name} \
        or raise "Can't find queue named #{queue_name.inspect}"
    end

  end

end
