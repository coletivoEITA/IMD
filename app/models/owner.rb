class Owner

  include MongoMapper::Document

  key :name, String, :unique => true, :required => true

  key :country, String

  # for companies
  key :formal_name, String
  key :cnpj, Array, :unique => true
  key :traded, Boolean
  key :classes, Array
  key :shares_quantity, Integer
  key :naics, Array
  key :stock_market, String
  key :stock_code, String

  many :balances, :dependent => :destroy_all
  many :shareholders, :class_name => 'CompanyShareholder', :foreign_key => :company_id, :dependent => :destroy_all

  validates_uniqueness_of :formal_name, :allow_nil => :true
  before_validation :assign_defaults

  def self.new_from_name(name, cnpj = nil)
    if cnpj
      owner = self.find_by_cnpj(cnpj)
      owner ||= self.new(:cnpj => cnpj)
      # do not replace original name
      owner.name ||= name
      owner
    else
      owner = self.find_by_name(name)
      owner ||= self.new(:name => name)
    end
  end
  def self.new_from_formal_name(formal_name, cnpj = nil)
    owner = self.all(:formal_name => formal_name, :cnpj => cnpj).first || self.new(:formal_name => formal_name)
    owner.add_cnpj if cnpj
    owner
  end

  def self.match_shareholders
    self.all.map do |company|
      company.match_shareholders
    end.compact
  end
  def match_shareholders
    shareholders = CompanyShareholder.all(:name => self.formal_name) + CompanyShareholder.all(:name => self.name)
    matches = shareholders.map do |shareholder|
      shareholder.company = self
      shareholder.save
    end
    if !matches.empty?
      {:self => matches}
    end
  end

  def value
    balances.first.revenue
  end
  def shareholders_value
    shareholders.inject(0){ |sum, sh| sum + sh.value }
  end

  def add_cnpj(cnpj)
    self.cnpj << cnpj unless self.cnpj.include?(cnpj)
  end

  protected

  def assign_defaults
    self.name ||= self.formal_name
  end

end

