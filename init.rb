require 'post_pinger'
require 'config'
ActiveRecord::Base.observers << :article_ping_observer
