class Balance

  include MongoMapper::Document

  key :source, String, :required => :true
  key :reference_date, String

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  MonthsReference = 12

  key :months, Integer, :default => MonthsReference
  key :total_active, Float, :default => 0
  key :patrimony, Float, :default => 0
  key :revenue, Float, :default => 0
  key :gross_profit, Float, :default => 0
  key :net_profit, Float, :default => 0
  key :currency, String

  validates_presence_of :company
  validates_uniqueness_of :reference_date, :scope => [:company_id, :source]

  def value(attr)
    (MonthsReference / self.months) * self.send(attr)
  end

end
