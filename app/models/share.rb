# coding: UTF-8

class Share

  include MongoMapper::Document
  timestamps!

  key :source, String, :required => :true
  key :reference_date, String, :required => :true

  key :sclass, String, :required => :true

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :name, String
  key :quantity, Fixnum
  key :percentage, Float
  key :owner_id, ObjectId
  belongs_to :owner

  validates_presence_of :company
  validates_presence_of :name
  validates_presence_of :owner
  validates_uniqueness_of :name, :scope => [:source, :company_id, :sclass, :reference_date]
  validates_numericality_of :quantity, :greater_than => 0.0, :allow_nil => true
  validates_numericality_of :percentage, :greater_than => 0.0, :allow_nil => true
  validate :quantity_xor_percentage

  before_validation :create_owner
  before_save :calculate_percentage

  scope :on, :sclass => 'ON'
  scope :pn, :sclass => 'PN'
  scope :with_sclass, lambda{ |sclass|
    sclass.blank? ? {:sclass.ne => nil} : {:sclass => sclass}
  }

  scope :with_reference_date, lambda{ |reference_date|
    reference_date.blank? ? {:reference_date.ne => nil} : {:reference_date => reference_date}
  }
  scope :lastest, :order => :reference_date.desc

  scope :greatest, :order => :percentage.desc

  def self.create_owners
    Share.each{ |s| s.create_owner }
  end

  def create_owner
    self.owner ||= Owner.first_or_new "#{self.source} associado", :name => self.name, :formal_name => self.name
    self.owner.save!
  end

  def control?
    self.percentage && self.percentage > 50
  end
  def parcial?
    self.percentage && self.percentage <= 50
  end

  def calculate_percentage
    return if self.quantity.blank?
    return if self.total.blank? or self.total.to_i.zero?

    self.percentage = (self.quantity / total.to_f) * 100
  end

  def total
    return @total if @total
    @total = self.company.shares_quantity[self.sclass]
    if @total.nil?
      sq = self.company.shares_quantity.select{ |sclass, quantity| sclass.starts_with?(self.sclass) }.first
      return unless sq
      @total = sq[1]
    end
    @total
  end

  def quantity=(value)
    self['quantity'] = value.to_i
  end

  def value(attr)
    (self.percentage/100) * self.company.value(attr)
  end

  protected

  def quantity_xor_percentage
    self.errors[:base] << 'Fill in percentage or quantity' if self.quantity.blank? and self.percentage.blank?
  end

end

