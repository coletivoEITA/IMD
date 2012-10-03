# coding: UTF-8

class NameEquivalence

  include MongoMapper::Document
  timestamps!

  key :name, String
  key :synonymous, String
  key :source, String

  validates_presence_of :name
  validates_presence_of :synonymous
  validates_uniqueness_of :name, :scope => [:synonymous, :source]

end
