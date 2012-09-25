class Owner

  include MongoMapper::Document

  key :name, String, :unique => true, :required => true
  key :country, String

  # for companies
  key :formal_name, String
  key :cgc, Array
  key :cnpj_root, String
  key :traded, Boolean
  key :classes, Array
  key :shares_quantity, Integer
  key :naics, Array
  key :stock_market, String
  key :stock_code, String

  key :direct_revenue, Float, :default => 0
  key :indirect_revenue, Float, :default => 0
  key :total_revenue, Float, :default => 0

  many :balances, :foreign_key => :company_id, :dependent => :destroy_all
  many :owners_shares, :class_name => 'Share', :foreign_key => :company_id, :dependent => :destroy_all
  many :owned_shares, :class_name => 'Share', :foreign_key => :owner_id, :dependent => :destroy_all

  # downcase versions
  key :name_d, String
  key :formal_name_d, String

  validates_uniqueness_of :formal_name, :allow_nil => true
  validates_uniqueness_of :cgc
  validates_uniqueness_of :cnpj_root, :allow_nil => true
  before_validation :assign_defaults
  before_save :assign_downcases
  validate :validate_cgc

  def self.find_or_create(cgc, name, formal_name)
    name_d = name.downcase if name
    formal_name_d = formal_name.downcase if formal_name

    owner_by_cgc = owner_by_name = owner_by_formal_name = nil
    owner_by_cgc = self.find_by_cgc(cgc)
    owner_by_name = self.find_by_name_d(name_d) || self.find_by_name_d(formal_name_d) if name
    owner_by_formal_name = self.find_by_formal_name_d(formal_name_d) || self.find_by_formal_name_d(name_d) if formal_name
    owner = owner_by_cgc || owner_by_name || owner_by_formal_name || self.new

    owner.name ||= name
    owner.add_cgc(cgc)
    owner.formal_name ||= formal_name
    owner
  end

  def self.find_by_cgc(cgc)
    if CgcHelper.cnpj?(cgc)
      self.find_by_cnpj_root CgcHelper.extract_cnpj_root(cgc)
    else
      super cgc
    end
  end

  def cnpj?
    CgcHelper.cnpj?(self.cgc.first)
  end
  def cpf?
    CgcHelper.cpf?(self.cgc.first)
  end

  def calculate_direct_value(attr)
    v = value(attr)
    self.send "direct_#{attr}=", v
    self.save
    v
  end
  def calculate_indirect_value(attr)
    def __recursion(company, attr, visited)
      pp company
      company.owned_shares.on.all.inject(0) do |sum, owned_share|
        if visited.include? owned_share.company
          0
        else
          visited << owned_share.company

          direct_value = owned_share.company.send("direct_#{attr}")
          direct_value = calculate_indirect_value(attr) if direct_value.zero?

          indirect_value = owned_share.company.send("indirect_#{attr}")
          if indirect_value.zero?
            indirect_value = __recursion(owned_share.company, attr, visited)
            # cache value
            owned_share.company.send("indirect_#{attr}=", indirect_value)
            owned_share.company.save
          end

          sum + owned_share.percentage * (direct_value + indirect_value)
        end
      end
    end

    visited = [self] # only indirect value, don't get own value
    v = __recursion(self, attr, visited)
    self.send "indirect_#{attr}=", v
    self.save
    v
  end
  def calculate_total_value(attr)
    calculate_direct_value(attr) + calculate_indirect_value(attr)
  end

  def calculate_revenue
    self.calculate_direct_value(:revenue)
    self.calculate_indirect_value(:revenue)
    self.total_revenue = self.direct_revenue + self.indirect_revenue
    self.save
  end

  def value(attr)
    return 0 if balances.first.nil?
    balances.first.value(attr)
  end

  def add_cgc(cgc)
    self.cgc << cgc unless self.cgc.include?(cgc)
  end

  protected

  def assign_defaults
    self.name ||= self.formal_name
    self.cnpj_root ||= CgcHelper.extract_cnpj_root(self.cgc.first) if self.cnpj?
  end

  def assign_downcases
    self.name_d = self.name.downcase
    self.formal_name_d = self.formal_name.downcase if self.formal_name
  end

  def validate_cgc
    self.errors.add 'Not a CPF or a CNPJ' if !self.cnpj? and !self.cpf?
  end

end

