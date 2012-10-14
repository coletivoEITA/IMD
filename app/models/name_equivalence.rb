# coding: UTF-8

class NameEquivalence

  include MongoMapper::Document
  timestamps!

  key :name, String
  key :synonymous, String
  key :source, String

  validates_presence_of :name
  validates_presence_of :synonymous
  validates_presence_of :scope
  validates_uniqueness_of :name, :scope => [:synonymous, :source]

  def self.replace(source, name)
    ne = NameEquivalence.first :synonymous => name, :source => source
    return name if ne.blank?
    ne.name
  end

end
