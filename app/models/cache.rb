# coding: UTF-8

class Cache

  include MongoMapper::Document
  timestamps!

  key :identifier, Hash, :required => :true
  key :content, String, :required => :true

  def self.match(method, args)
  end

  def self.enable
    Mechanize.alias_method_chain :get, :with_cache
    Mechanize.define_method :get_with_cache do |*args|
    end
  end

end
