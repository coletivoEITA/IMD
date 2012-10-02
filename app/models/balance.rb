# coding: UTF-8

class Balance

  include MongoMapper::Document
  timestamps!

  key :source, String, :required => :true
  key :reference_date, String, :required => :true

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  MonthsReference = 12

  key :months, Integer, :default => MonthsReference
  key :currency, String

  key :total_active, Float, :default => 0
  key :patrimony, Float, :default => 0
  key :revenue, Float, :default => 0
  key :gross_profit, Float, :default => 0
  key :net_profit, Float, :default => 0

  validates_presence_of :company
  validates_uniqueness_of :reference_date, :scope => [:source, :company_id]
  validates_presence_of :months
  validates_presence_of :currency

  scope :economatica, :source => 'Economatica'
  scope :exame, :source => 'Exame'

  scope :with_reference_date, lambda{ |reference_date|
    reference_date.blank? ? {:reference_date.ne => nil} : {:reference_date => reference_date}
  }
  scope :lastest, :order => :reference_date.desc

  def value(attr)
    (MonthsReference / self.months) * self.send(attr)
  end

end
