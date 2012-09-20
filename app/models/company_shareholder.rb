class CompanyShareholder

  include MongoMapper::Document

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  key :type, String
  key :reference_date, String

  key :name, String
  key :percentage, Float
  key :owner_id, ObjectId
  belongs_to :owner

  validates_presence_of :company
  validates_uniqueness_of :name, :scope => [:company_id, :type, :reference_date]
  validates_numericality_of :percentage, :greater_than => 0.0

  before_save :create_owner

  scope :on, :type => 'ON'
  scope :pn, :type => 'PN'

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

  def value(attr)
    return 0 unless company
    self.percentage * self.company.value(attr)
  end

  protected

  def create_owner
    self.owner ||= Owner.find_or_create self.name
    self.owner.save!
  end

end

