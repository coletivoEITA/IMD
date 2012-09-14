class CompanyShareholder

  include MongoMapper::Document

  key :company_id, ObjectId
  belongs_to :company

  key :type, String
  key :period, String

  key :name, String
  key :percentage, Float

  validates_numericality_of :percentage, :greater_than => 0.0

end

