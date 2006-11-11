require 'post_pinger'
ActiveRecord::Base.observers << :article_ping_observer
