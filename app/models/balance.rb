class Balance

  include MongoMapper::Document

  key :company_id, ObjectId
  belongs_to :company

  key :months, Integer
  key :total_active, Float
  key :patrimony, Float
  key :revenue, Float
  key :gross_profit, Float
  key :net_profit, Float
  key :currency, String

end
