class CompanyMember

  include MongoMapper::Document

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :member_id, ObjectId, :required => :true
  belongs_to :member, :class_name => 'Owner'

  key :qualification, String
  key :participation, Float
  key :entrance_date, String

end

