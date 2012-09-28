class Candidacy

  include MongoMapper::Document

  key :owner_id, ObjectId, :required => :true
  belongs_to :owner

  key :year, Integer
  key :role, String
  key :party, String
  key :state, String
  key :city, String
  key :status, String

  #validates_inclusion_of :status, :in => %w(elected not_elected), :allow_nil => true

  validates_uniqueness_of :year, :scope => [:owner_id]

end
