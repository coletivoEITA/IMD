class CompanyMember

  include MongoMapper::Document
  timestamps!

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :member_id, ObjectId, :required => :true
  belongs_to :member, :class_name => 'Owner'

  key :qualification, String
  key :participation, Float
  key :entrance_date, String

  validates_presence_of :company
  validates_presence_of :member
  validates_uniqueness_of :company_id, :scope => [:member_id]

end

