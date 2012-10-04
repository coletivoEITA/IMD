# coding: UTF-8

class Donation

  include MongoMapper::Document
  timestamps!

  key :candidacy_id, ObjectId, :required => :true
  belongs_to :candidacy

  key :grantor_id, ObjectId, :required => :true
  belongs_to :grantor, :class_name => 'Owner'

  key :value, Float, :required => :true
  key :type, String

  extend MongoCaching::ClassMethods
  cache_associated :state, :from => :candidacy
  cache_associated :city, :from => :candidacy

  cache_associated :candidate_id, :from => :candidacy
  belongs_to :candidate, :class_name => 'Owner'

  validates_presence_of :value
  validates_presence_of :candidacy
  validates_presence_of :grantor
  validates_numericality_of :value
  validates_inclusion_of :type, :in => %w(direct committee), :allow_nil => true

  scope :direct, :type => 'direct'
  scope :committee, :type => 'committee'

end
