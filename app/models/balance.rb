class Balance

  include MongoMapper::Document

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :reference_date, String

  key :months, Integer
  key :total_active, Float
  key :patrimony, Float
  key :revenue, Float
  key :gross_profit, Float
  key :net_profit, Float
  key :currency, String

  validates_presence_of :company
  validates_uniqueness_of :reference_date, :scope => :owner_id

end
