require 'yaml'

module Puppet::Parser::Functions
  newfunction(:policy_engine_test_config, :type => :rvalue) do |args|
    interpreter, output_format, expected_output, expected_exit_code, tags, metadata_file, payload_file = args


    cfg = {:interpreter => interpreter,
     :expected_output => expected_output,
     :output_format => output_format,
     :metadata_file => metadata_file,
     :tags => tags,
     :payload_file => payload_file,
    }

    if expected_exit_code.is_a? Integer
      cfg[:expected_exit_code] = Integer(expected_exit_code)
      cfg.delete(:expected_output)
    elsif expected_exit_code.is_a?(Array)
      cfg[:expected_exit_code] = expected_exit_code.map do |code|
        Integer(code)
      end
      cfg.delete(:expected_output)
    end

    cfg.to_yaml
  end
end
