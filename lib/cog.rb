
require_relative 'cog/bundle'
require_relative 'cog/config'
require_relative 'cog/command'
require_relative 'cog/aggregate_command'
require_relative 'cog/request'
require_relative 'cog/response'
require_relative 'cog/version'

require_relative 'cog/service'
require_relative 'cog/services/memory'
require_relative 'cog/services/metadata'

class Cog
  def self.bundle(name)
    bundle = Cog::Bundle.new(name)
    yield bundle if block_given?
    bundle.run_command
  end
end
