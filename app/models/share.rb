class Share

  include MongoMapper::Document
  timestamps!

  key :type, String
  key :reference_date, String

  key :name, String
  key :percentage, Float
  key :owner_id, ObjectId
  belongs_to :owner

  key :company_id, ObjectId, :required => :true
  belongs_to :company, :class_name => 'Owner'

  validates_presence_of :company
  validates_presence_of :name
  validates_uniqueness_of :name, :scope => [:company_id, :type, :reference_date]
  validates_numericality_of :percentage, :greater_than => 0.0

  before_save :create_owner

  scope :on, :type => 'ON'
  scope :pn, :type => 'PN'

  def self.create_owners
    Share.each{ |s| s.create_owner }
  end

  def create_owner
    self.owner ||= Owner.find_or_create nil, self.name, self.name
    self.owner.save!
  end

  def value(attr)
    (self.percentage/100) * self.company.value(attr)
  end

  protected

end

