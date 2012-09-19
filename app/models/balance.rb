class Balance

  include MongoMapper::Document

  key :owner_id, ObjectId, :required => :true
  belongs_to :owner

  key :reference_date, String

  key :months, Integer
  key :total_active, Float
  key :patrimony, Float
  key :revenue, Float
  key :gross_profit, Float
  key :net_profit, Float
  key :currency, String

  validates_uniqueness_of :reference_date, :scope => :owner_id

end
