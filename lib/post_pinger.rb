require 'thread'

class ArticlePingObserver < ActiveRecord::Observer
  observe Article
  SERVICES = [ "http://rpc.pingomatic.com/",
#               "http://localhost:3000/",
#               "http://rpc.technorati.com/rpc/ping",
#               "http://ping.syndic8.com/xmlrpc.php",
  ]

  def after_save( article )
    return unless article.published?

    SERVICES.each do |surl|
      Thread.new(surl, article) do |url, art|
        ping(url, art)
      end
    end     
  end


  private
  def logger
    RAILS_DEFAULT_LOGGER
  end

  def ping(url, article)
    # see the weblogs ping spec @ http://www.weblogs.com/api.html
    logger.info "sending weblog ping -> #{url}"

    cli = XMLRPC::Client.new2(url)
    title = article.site.title
    url = article.site.akismet_url

    feed_url = "%s/feed/atom.xml" % article.site.akismet_url
    tags = article.tags.join('|') # spec want's tags pipe delimeted

    res = cli.call2( 'weblogUpdates.extendedPing', title, url, feed_url, tags )
    logger.info "ping result => '#{res}'"
    # not sure if we care about the result...?
  rescue
    logger.error "unable to send weblog ping -> #{url}"
    # ignore ?
  end
                              
end
