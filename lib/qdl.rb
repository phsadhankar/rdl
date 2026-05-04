# This wrapper file allows us to completely disable QDL in certain modes.
if defined?(Rails)
  require 'active_record' if !defined?(ActiveRecord)
  require 'qdl/boot_rails'
else
  require 'qdl/boot'
end
