# coding: UTF-8

class Share

  include MongoMapper::Document
  timestamps!

  key :source, String, :required => :true
  key :reference_date, Time, :required => :true, :default => $balance_reference_date
  key :sclass, String, :required => :true

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :name, String
  key :quantity, Fixnum
  key :total, Fixnum
  key :percentage, Float
  key :owner_id, ObjectId
  belongs_to :owner

  key :relative_participation, Float
  alias_method :participation, :relative_participation

  key :source_detail, String

  key :name_n, String

  # external references
  key :econoinfo_id, Integer

  validates_presence_of :company
  validates_presence_of :owner
  validates_presence_of :name
  validates_presence_of :name_n
  validates_uniqueness_of :name, :scope => [:source, :company_id, :sclass, :reference_date]
  validates_numericality_of :quantity, :greater_than => 0.0, :allow_nil => true
  validates_numericality_of :percentage, :greater_than => 0.0, :allow_nil => true
  validate :company_differ_from_owner
  #validate :quantity_xor_percentage

  before_validation :create_owner
  before_validation :calculate_percentage
  before_validation :normalize_fields

  scope :on, :sclass => 'ON'
  scope :pn, :sclass => 'PN'
  scope :with_sclass, lambda{ |sclass|
    sclass.blank? ? {:sclass.ne => nil} : {:sclass => sclass}
  }

  scope :with_reference_date, lambda{ |reference_date|
    reference_date.blank? ? {:reference_date.ne => nil} : {:reference_date => reference_date}
  }
  scope :latest, :order => :reference_date.desc

  scope :greatest, :order => :percentage.desc

  def self.create_owners
    Share.each{ |s| s.create_owner }
  end

  def create_owner
    return if self.owner
    self.owner = Owner.first_or_new "#{self.source} associado", :name => self.name, :formal_name => self.name
    self.owner.save!
  end

  def control?
    !self.participation.nil? && self.participation > 0.5
  end
  def parcial?
    self.participation.nil? || self.participation <= 0.5
  end

  def total
    return self['total'] if self['total']
    # TODO: try to guess from siblings
  end

  def quantity=(value)
    value = value.to_i
    value = nil if value.zero?
    self['quantity'] = value
  end

  def value attr
    self.participation * self.company.value(attr)
  end

  def raw_participation
    self.percentage.nil? ? 0 : self.percentage/100
  end

  def calculate_percentage
    # nil instead of zero
    self.percentage = nil if percentage and percentage.zero?

    return if self.quantity.blank?
    return if self.total.blank? or self.total.to_i.zero?

    self.percentage = (self.quantity / total.to_f) * 100
    # fix some data from economatica
    self.percentage /= 1000 if (self.percentage / 1000) > 1
    self.percentage
  end

  def calculate_relative_participation
    if self.percentage.nil?
      self.relative_participation = nil
      return
    end
    self.relative_participation = (self.percentage ** 2) / self.company.sum_percentages_squares
  end

  protected

  def normalize_fields
    self.name_n = self.name.name_normalization
  end

  def company_differ_from_owner
    self.errors[:owner] << "Can't have a share of itself" if company == owner
  end

end

