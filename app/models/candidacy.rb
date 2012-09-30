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

  #in case there is any data to access from www.asclaras.org later
  key :asclaras_id, Integer

  many :donations

  validates_presence_of :candidate
  validates_uniqueness_of :year, :scope => [:candidate_id]
  validates_inclusion_of :status, :in => %w(elected not_elected substitute), :allow_nil => true

  def top_donations(l = 10)
	donation_list = donations.sort('value desc').limit(l)
    #print grantor_nama and donation value on console
    donation_list.each do |d|
      pp d.grantor.name + '-'+ d.value.to_s
    end
    donation_list
  end

  def donations_by_party_candidate(party=nil,candidate_name=nil,candidate_id_asclaras=nil)
     
  end
end
