class Owner

  include MongoMapper::Document

  key :name, String, :unique => true, :required => true
  key :country, String

  # for companies
  key :formal_name, String
  key :cnpj, Array
  key :cnpj_root, String
  key :traded, Boolean
  key :classes, Array
  key :shares_quantity, Integer
  key :naics, Array
  key :stock_market, String
  key :stock_code, String

  many :balances, :dependent => :destroy_all
  many :shareholders, :class_name => 'CompanyShareholder', :foreign_key => :company_id, :dependent => :destroy_all

  # downcase versions
  key :name_d, String
  key :formal_name_d, String

  validates_uniqueness_of :formal_name, :allow_nil => :true
  validates_uniqueness_of :cnpj, :allow_nil => :true
  validates_uniqueness_of :cnpj_root, :allow_nil => :true
  before_validation :assign_defaults
  before_save :assign_downcases

  def self.find_or_create(name, formal_name = nil, cnpj = nil)
    name_d = name.downcase if name
    formal_name_d = formal_name.downcase if formal_name

    owner_by_cnpj = self.find_by_cnpj(cnpj)
    owner_by_name = self.find_by_name_d(name_d) || self.find_by_name_d(formal_name_d) if name
    owner_by_formal_name = self.find_by_formal_name_d(formal_name_d) || self.find_by_formal_name_d(name_d) if formal_name
    owner = owner_by_cnpj || owner_by_name || owner_by_formal_name || self.new

    owner.name ||= name
    owner.add_cnpj(cnpj) if cnpj
    owner.formal_name ||= formal_name
    owner
  end

  def self.extract_cnpj_root(cnpj)
    cnpj[0,8] if cnpj
  end
  def self.find_by_cnpj(cnpj)
    self.find_by_cnpj_root self.extract_cnpj_root(cnpj)
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
    self.cnpj_root ||= Owner.extract_cnpj_root(self.cnpj.first)
  end

  def assign_downcases
    self.name_d = self.name.downcase
    self.formal_name_d = self.formal_name.downcase if self.formal_name
  end

end

