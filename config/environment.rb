

require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  config.action_controller.session = {
    :session_key => '_restfulauth_session',
    :secret => 'd8db38ea6f1929f4e2c7e5668ab9410e9e752200721a7f4b75358eb3ef3c5a80258eb5e2436b142084892582b548597ed27056efec329a3edb98c2dc4928f8eb'
  }

  config.action_controller.session_store = :active_record_store
  config.active_record.observers = :user_observer
end