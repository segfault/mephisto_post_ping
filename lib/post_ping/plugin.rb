# $Id$
module MephistoPlugins
  class PostPinger < MephistoPlugin
    author 'Mark Guzman'
    version '$Rev$'.gsub( "Rev: ", "" )
    notes "Send Weblogs Pings when articles are published"
    homepage "http://hasno.info/2006/11/11/mephisto-plugins"

    class Schema < ActiveRecord::Migration
      def self.install
      end

      def self.uninstall
      end
    end

  end
end
