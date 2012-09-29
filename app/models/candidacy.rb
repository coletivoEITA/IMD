class Candidacy

  include MongoMapper::Document
  timestamps!

  key :candidate_id, ObjectId, :required => :true
  belongs_to :candidate, :class_name => 'Owner'

  key :year, Integer, :required => :true

  key :role, String
  key :party, String
  key :state, String
  key :city, String
  key :status, String

  many :donations

  validates_presence_of :candidate
  validates_uniqueness_of :year, :scope => [:candidate_id]
  validates_inclusion_of :status, :in => %w(elected not_elected substitute), :allow_nil => true

end
