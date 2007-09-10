# $Id$
# Mephisto Post Pinger plugin
require 'thread'
require 'net/http'
require 'uri'

class ArticlePingObserver < ActiveRecord::Observer
  observe Article
  VERSION = "$Rev$"
  SERVICES = [] 

  def after_save( article )
    return unless article.published?

    SERVICES.each do |sinfo|
      next if sinfo[:section] && article.assigned_sections.select { |sec| sec if sec.section.name == sinfo[:section].to_s }.length == 0
      next if sinfo[:tag] && article.tags(true).select { |tag| true if tag[:name] == sinfo[:tag].to_s }.length == 0

      Thread.new(sinfo, article) do |info, art|
        case info[:type]
        when :rest
          rest_ping( info[:url], art )
        when :pom_get # ping-o-matic get
          pom_get_ping( info[:url], art, info[:extras] )
        else # :xmlrpc or default
          xmlrpc_ping( info[:url], art )
        end

      end
    end
  end


  private
  def logger
    RAILS_DEFAULT_LOGGER
  end

  def pom_get_ping(url, article, extra_fields=[])
    logger.info "sending http get ping-o-matic ping -> #{url}"

    #article.site.host is not currently populated with anything useful
    #we'll use the akismet_url for now
    blog_url = article.site.akismet_url
    rss_url = "%s/feed" % blog_url

    get_url = "%s?title=%s&blogurl=%s&rssurl=%s" % [ url, article.site.title, blog_url, rss_url ]
    extra_fields.each { |extra_url| get_url << "&" + extra_url }

    res = Net::HTTP.get( URI.parse( URI.escape( get_url ) ) )

    logger.info "http get ping result => '#{res}'"
  rescue
    logger.error "unable to send http get ping-o-matic ping -> #{url}"
  end


  def rest_ping(url, article)
    # see the weblogs rest ping spec @ http://www.weblogs.com/api.html
    logger.info "sending rest weblog ping -> #{url}"

    uri = URI.parse( url )
    post_info = { "name" => article.site.title,
                  "url" => article.site.akismet_url }
    raw_res = Net::HTTP.post_form( uri, post_info )

    raise Exception.new("http error") unless raw_res.kind_of? Net::HTTPSuccess
    res = raw_res.body

    logger.info "rest ping result => '#{res}'"
  rescue
    logger.error "unable to send rest weblog ping -> #{url}"
  end


  def xmlrpc_ping(url, article)
    # see the weblogs xmlrpc ping spec @ http://www.weblogs.com/api.html
    logger.info "sending xmlrpc weblog ping -> #{url}"

    cli = XMLRPC::Client.new2(url)
    title = article.site.title
    url = article.site.akismet_url

    feed_url = "%s/feed/atom.xml" % article.site.akismet_url
    tags = article.tags.join('|') # spec want's tags pipe delimeted

    res = cli.call2( 'weblogUpdates.extendedPing', title, url, feed_url, tags )
    logger.info "xmlrpc ping result => '#{res}'"
    # not sure if we care about the result...?
  rescue
    logger.error "unable to send xmlrpc weblog ping -> #{url}"
    # ignore ?
  end

end

require 'config'
