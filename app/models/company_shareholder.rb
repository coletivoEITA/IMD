class CompanyShareholder

  include MongoMapper::Document

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :type, String
  key :reference_date, String

  key :name, String
  key :percentage, Float
  key :owner_id, ObjectId, :required => :true
  belongs_to :owner

  validates_uniqueness_of :name, :scope => :company_id
  validates_numericality_of :percentage, :greater_than => 0.0
  before_validation :assign_defaults

  def self.match_companies
    self.all.map do |company|
      company.match_company
    end.compact
  end
  def match_company
    self.company = Owner.all(:formal_name => self.name).first || Owner.all(:name => self.name).first
    if self.company
      self.save
      {self.company => self}
    end
  end

  def value
    return 0 unless company
    self.percentage * other_company.value
  end

  protected

  def assign_defaults
    self.owner ||= Owner.find_or_create self.name
    self.owner.save!
  end

end

