class Donation

  include MongoMapper::Document
  timestamps!

  key :candidacy_id, ObjectId, :required => :true
  belongs_to :candidacy

  key :owner_id, ObjectId, :required => :true
  belongs_to :owner

  key :value, BigDecimal
  key :type, String

  validates_presence_of :value
  validates_numericality_of :value

  #validates_inclusion_of :type, :in => %w(direct committee), :allow_nil => true

end
