class Cog
  class Bundle
    attr_reader :name

    def initialize(name, base_dir: nil)
      @name = name
      @base_dir = base_dir || File.dirname($0)
      @module = create_bundle_module
    end

    def create_bundle_module
      module_name = classify(@name)

      Object.const_set('CogCmd', Module.new) unless Object.const_defined?('CogCmd')

      if CogCmd.const_defined?(module_name)
        CogCmd.const_get(module_name)
      else
        CogCmd.const_set(module_name, Module.new)
      end
    end

    def command
      @command ||= command_instance(ENV['COG_COMMAND'])
    end

    def command_instance(command_name)
      command_path = command_name.split('-')
      require File.join(@base_dir, 'lib', 'cog_cmd', @name, *command_path)

      # translate snake-case command names to camel case
      command_class = classify(command_name)

      @module.const_get(command_class).new
    end

    def run_command
      command.execute
    rescue Cog::Abort => exception
      # Abort will end command execution and abort the pipeline
      response = Cog::Response.new
      response.content = exception.message
      response.abort
      response.send
    rescue Cog::Stop => exception
      # Stop will end command execution but the pipeline will continue
      response = Cog::Response.new
      response['body'] = exception.message
      response.send
    end

    private

    # Converts strings to UpperCamelCase.
    # Also converts '/' and '-' to '::' for converting paths to namespaces

    # Examples:
    #   camelize('cog_cmd')        # => CogCmd
    #   camelize('cog_cmd/my_bundle') # => CogCmd::MyBundle
    #   camelize('cog_cmd-my_bundle') # => CogCmd::MyBundle
    def classify(term)
      term
        .sub(/^[a-z\d]*/, &:capitalize)
        .gsub(%r{(?:_|(/|\-))([a-z\d]*)}) { "#{$1}#{$2.capitalize}" }
        .gsub(%r{/|\-}, '::'.freeze)
    end
  end
end
