require 'vendor/plugins/permalink_fu/lib/permalink_fu'
require 'vendor/plugins/permalink_fu/init'
require 'post_pinger'
require 'config'
ActiveRecord::Base.observers << :article_ping_observer
