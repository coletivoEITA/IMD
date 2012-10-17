# coding: UTF-8

class Cache

  include MongoMapper::Document
  timestamps!

  key :identifier, Hash, :required => :true
  key :content, String, :required => :true

  def self.request_page(mech, method, *args)
    identifier = {:method => method, :args => args}
    cache = self.find_by_identifier identifier

    if cache
      uri = URI.parse args.first
      page = Mechanize::Page.new uri, nil, cache.content, nil, mech
    else
      page = mech.send("#{method}_without_cache", *args)
      Cache.create! :identifier => identifier, :content => page.body
    end

    page
  end

  Methods = [:get, :post]

  def self.enable
    Cache.disable
    Methods.each do |method|
      Mechanize.send(:define_method, "#{method}_with_cache") do |*args|
        Cache.request_page(self, method, *args)
      end
      Mechanize.alias_method_chain method, :cache
    end
  end

  def self.disable
    Methods.each do |method|
      next unless Mechanize.respond_to?("#{method}_with_cache")
      Mechanize.send :alias_method, "#{method}_with_cache", method
    end
  end

end
