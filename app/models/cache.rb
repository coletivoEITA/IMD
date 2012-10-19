# coding: UTF-8

class Cache

  include MongoMapper::Document
  timestamps!

  key :identifier, Hash, :required => :true
  key :content, String, :required => :true
  key :encoding, String

  key :url, String
  key :url_host, String

  before_save :set_url_host
  before_save :assign_defaults

  def self.request_page(mech, method, *args)
    identifier = {:method => method, :args => args}
    cache = Cache.first :identifier => identifier

    uri = URI.parse args.first
    if cache
      content = cache.encoding ? cache.content.encodef(cache.encoding, 'UTF-8') : cache.content
      page = Mechanize::Page.new uri, nil, content, nil, mech
      puts "Cache hit for #{uri}"
    else
      page = mech.send("#{method}_without_cache", *args)
      encoding = page.encoding
      content = page.content.encodef('UTF-8', encoding)
      cache = Cache.create! :identifier => identifier, :url => uri.to_s,
        :content => content, :encoding => encoding
    end

    page
  end

  Methods = [:get, :post]

  def self.enable
    #Cache.disable
    Methods.each do |method|
      next if Mechanize.respond_to?("#{method}_with_cache")
      Mechanize.send(:define_method, "#{method}_with_cache") do |*args|
        Cache.request_page self, method, *args
      end
      Mechanize.alias_method_chain method, :cache
    end
  end

  def self.disable
    Methods.each do |method|
      next unless Mechanize.respond_to?("#{method}_without_cache")
      Mechanize.send :alias_method, "#{method}_without_cache", method
    end
  end

  def self.test
    Cache.enable
    m = Mechanize.new
    m.get 'http://kernel.org'
    m.get 'http://kernel.org'
    true
  end

  protected

  def set_url_host
    self.url_host = URI.parse(self.url).host unless self.url.blank?
  end

  def assign_defaults
  end

end
