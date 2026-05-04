if Rails.env.development? || Rails.env.test?
  require 'qdl/boot'
  require 'types/core'

  require_relative "../types/rails/_helpers.rb" # load type aliases first
  Dir[File.dirname(__FILE__) + "/../types/rails/**/*.rb"].each { |f| require f }
  class QDLRailtie < ::Rails::Railtie
    config.after_initialize do
      QDL.load_rails_schema
    end
  end
elsif Rails.env.production?
  require 'qdl_disable'
  class ActionController::Base
    def self.params_type(typs); end
  end
else
  raise RuntimeError, "Don't know what to do in Rails environment #{Rails.env}"
end

