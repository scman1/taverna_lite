# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
if ActiveSupport::TestCase.method_defined?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("../fixtures", __FILE__)
end


# Code added from https://github.com/rails/rails/issues/4971
# to fix non running tests

class ActiveSupport::TestCase
  fixtures :all
end

module TavernaLite
  class ActionController::TestCase
    setup do
      @routes = Engine.routes
    end
  end
end

# still not loading dummy fixtures
