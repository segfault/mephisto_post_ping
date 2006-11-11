class ArticlePingObserver < ActiveRecord::Observer
  observe Article
  SERVICES = [ "http://rpc.pingomatic.com/",
#               "http://rpc.technorati.com/rpc/ping",
#               "http://ping.syndic8.com/xmlrpc.php",
  ]

  def after_save( article )
    ping_all( article )
  end

  def after_update( article )
    ping_all( article )
  end 


  private
  def ping_all(article)
    return unless article.published?

    SERVICES.each do |url|
      ping(url, article)
    end  
  end

  def ping(url, article)
    # see the weblogs ping spec @ http://www.weblogs.com/api.html
    cli = XMLRPC::Client.new2(url)
    title = article.site.title
    url = article.site.akismet_url
    feed_url = "%s/feed/atom.xml" % article.site.akismet_url
    tags = article.tags.join('|') # spec want's tags pipe delimeted
    res = cli.call2( 'weblogUpdates.extendedPing', title, url, feed_url, tags )
    # not sure if we care about the result...?
  end
                              
end
