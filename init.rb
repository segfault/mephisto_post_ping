# $Id$
require 'post_ping/plugin'
ActiveRecord::Base.observers << :article_ping_observer
