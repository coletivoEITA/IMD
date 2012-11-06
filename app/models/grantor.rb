# coding: UTF-8

class Grantor

  include MongoMapper::Document
  timestamps!

  key :owner_id, ObjectId, :required => :true
  belongs_to :owner, :class_name => 'Owner'

  key :year, Integer, :required => :true

  # external references
  key :asclaras_id, Integer

end
