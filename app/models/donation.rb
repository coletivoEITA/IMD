class Donation

  include MongoMapper::Document
  timestamps!

  key :candidacy_id, ObjectId, :required => :true
  belongs_to :candidacy

  key :grantor_id, ObjectId, :required => :true
  belongs_to :grantor, :class_name => 'Owner'

  key :value, Float, :required => :true
  key :type, String

  validates_presence_of :value
  validates_presence_of :candidacy
  validates_presence_of :grantor
  validates_numericality_of :value
  validates_inclusion_of :type, :in => %w(direct committee), :allow_nil => true

end
