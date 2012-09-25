class Balance

  include MongoMapper::Document

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :reference_date, String

  MonthsReference = 12

  key :months, Integer, :default => MonthsReference
  key :total_active, Float, :default => 0
  key :patrimony, Float, :default => 0
  key :revenue, Float, :default => 0
  key :gross_profit, Float, :default => 0
  key :net_profit, Float, :default => 0
  key :currency, String

  validates_presence_of :company
  validates_uniqueness_of :reference_date, :scope => :company_id
  validates_presence_of :revenue

  def value(attr)
    (MonthsReference / self.months) * send(attr)
  end

end
