# coding: UTF-8

class Owner

  include MongoMapper::Document
  timestamps!

  key :name, String, :unique => :true, :required => :true
  key :source, String, :required => :true

  # companies
  key :formal_name, String
  key :cgc, Array
  key :cnpj_root, String
  key :capital_type, String
  # group
  #key :group_id, ObjectId
  #belongs_to :group, :class_name => 'OwnerGroup'
  # company categorization
  key :naics, Array
  key :sector, String
  key :economatica_sector, String
  # company stock info
  key :classes, Array
  key :traded, Boolean
  key :stock_market, String
  key :stock_code, String
  key :shares_quantity, Hash # {'class' => 'quantity'}

  key :members_count, Integer # nil means members not loaded

  key :address, String
  key :city, String
  key :state, String
  key :country, String
  key :phone, String
  key :website, String

  key :own_revenue, Float, :default => 0
  key :indirect_revenue, Float, :default => 0
  key :total_revenue, Float, :default => 0

  key :own_patrimony, Float, :default => 0
  key :indirect_patrimony, Float, :default => 0
  key :total_patrimony, Float, :default => 0

  # normalized versions
  key :name_n, String
  key :formal_name_n, String

  #in case there is any data to access from www.asclaras.org later
  key :asclaras_id, Integer

  many :balances, :foreign_key => :company_id, :dependent => :destroy_all
  many :owners_shares, :class_name => 'Share', :foreign_key => :company_id, :dependent => :destroy_all
  many :owned_shares, :class_name => 'Share', :foreign_key => :owner_id, :dependent => :destroy_all

  many :members, :class_name => 'CompanyMember', :foreign_key => :company_id, :dependent => :destroy_all
  many :members_of, :class_name => 'CompanyMember', :foreign_key => :member_id, :dependent => :destroy_all

  many :candidacies, :class_name => 'Candidacy', :foreign_key => :candidate_id, :dependent => :destroy_all

  many :donations_made, :class_name => 'Donation', :foreign_key => :grantor_id, :dependent => :destroy_all
  many :donations_received, :class_name => 'Donation', :foreign_key => :candidate_id, :dependent => :destroy_all

  validates_uniqueness_of :formal_name, :allow_nil => true
  validates_uniqueness_of :cgc, :allow_nil => true
  validates_uniqueness_of :cnpj_root, :allow_nil => true
  validates_inclusion_of :capital_type, :in => %w(private state), :allow_nil => true
  validate :validate_cgc

  before_validation :assign_defaults
  before_save :normalize_fields

  def self.first_or_new(source, attributes = {})
    cgc = attributes[:cgc]
    name = attributes[:name]
    formal_name = attributes[:formal_name]

    name_n = name.filter_normalization if name
    formal_name_n = formal_name.filter_normalization if formal_name

    exact_match = self.first(attributes)
    owner_by_cgc = owner_by_name = owner_by_formal_name = nil
    owner_by_cgc = self.find_by_cgc(cgc) if cgc
    owner_by_name = self.find_by_name_n(name_n) if name
    owner_by_formal_name = self.find_by_formal_name_n(formal_name_n) if formal_name
    owner = exact_match || owner_by_cgc || owner_by_name || owner_by_formal_name || self.new

    owner.source ||= source
    owner.add_cgc(cgc)
    attributes.each do |attr, value|
      next if attr.to_s == 'cgc'
      owner.send("#{attr}=", owner.send(attr) || value)
    end
    owner
  end

  def self.find_by_cgc(cgc)
    return nil if cgc.blank?
    cgc = CgcHelper.format cgc
    if CgcHelper.cnpj?(cgc)
      self.find_by_cnpj_root(CgcHelper.extract_cnpj_root(cgc)) || super(cgc)
    else
      super(cgc)
    end
  end

  def cnpj?
    CgcHelper.cnpj?(self.cgc.first)
  end
  def cpf?
    CgcHelper.cpf?(self.cgc.first)
  end

  def value(attr, reference_date = nil)
    scoped = self.balances.with_reference_date(reference_date)
    balance = scoped.economatica.first || scoped.valor.first
    return 0 if balance.nil?
    balance.value(attr)
  end

  def indirect_parcial_controlled_companies(share_reference_date = nil)

    def __recursion(company, percentage, share_reference_date, visited = [])
      shares = company.owned_shares.on.greatest.with_reference_date(share_reference_date)
      list = []

      if company != visited.first # only indirect
        owned = shares.map do |owned_share|
          owned_company = owned_share.company
          next if owned_share.percentage.nil?
          next if owned_share.control?

          "#{owned_company.name} (#{owned_share.percentage.c}%, final=#{((owned_share.percentage*percentage)/100.0).c}%)"
        end.join(' ')
        list << "#{company.name} (#{percentage.c}): (#{owned})\n" if percentage <= 50
      end

      list += shares.map do |owned_share|
        owned_company = owned_share.company
        next if owned_share.percentage.nil?

        next if visited.include? owned_company
        visited << owned_company

        p = percentage ? owned_share.percentage*percentage : owned_share.percentage
        __recursion(owned_company, p, share_reference_date, visited)
      end

      list
    end

    __recursion(self, nil, share_reference_date, [self])
  end
  def indirect_total_controlled_companies(share_reference_date = nil)

    def __recursion(company, share_reference_date, visited = [])
      company.owned_shares.on.greatest.with_reference_date(share_reference_date).map do |owned_share|
        owned_company = owned_share.company

        next if visited.include? owned_company
        visited << owned_company

        next unless owned_share.control?

        list = []
        if company != visited.first # only indirect
          list << "#{owned_company.name} (controlada por #{company.name})"
        end

        list << __recursion(owned_company, share_reference_date, visited)
        list
      end
    end

    __recursion(self, share_reference_date, [self]).flatten.compact
  end

  def controlled_companies(share_reference_date = nil)

    def __recursion(company, share_reference_date, visited = [])
      company.owned_shares.on.greatest.with_reference_date(share_reference_date).each do |owned_share|
        owned_company = owned_share.company

        next if visited.include? owned_company
        visited << owned_company

        __recursion(owned_company, share_reference_date, visited)
      end
    end

    visited = [self]
    __recursion(self, share_reference_date, visited)
    visited
  end

  def calculate_own_value(attr = :revenue, balance_reference_date = nil)
    v = value(attr, balance_reference_date)
    self.send "own_#{attr}=", v
    self.save
    v
  end
  def calculate_indirect_value(attr = :revenue, balance_reference_date = nil, share_reference_date = nil)

    def __recursion(company, attr = :revenue, balance_reference_date = nil, share_reference_date = nil,
                    visited = [], controlled_companies = [])

      company.owned_shares.on.with_reference_date(share_reference_date).inject(0) do |sum, owned_share|
        owned_company = owned_share.company

        next 0 if owned_share.percentage.nil?

        is_controller = owned_share.control?
        #next 0 if not is_controller and controlled_companies.include?(owned_company)

        next 0 if visited.include? owned_company
        visited << owned_company

        total_value = owned_company.send("total_#{attr}")
        if total_value.zero?
          own_value = owned_company.send("own_#{attr}")
          own_value = owned_company.calculate_own_value(attr, balance_reference_date)

          indirect_value = owned_company.send("indirect_#{attr}")
          if indirect_value.zero?
            indirect_value = __recursion owned_company, attr, balance_reference_date, share_reference_date, visited
            # cache value
            owned_company.send("indirect_#{attr}=", indirect_value)
          end

          total_value = own_value + indirect_value
          # cache value
          owned_company.send("total_#{attr}=", total_value)
          owned_company.save
        end

        w = is_controller ? 1 : owned_share.percentage/100

        sum + w * total_value
      end
    end

    v = __recursion(self, attr, balance_reference_date, share_reference_date, [self], [])
    self.send "indirect_#{attr}=", v
    self.save
    v
  end
  def calculate_value(attr = :revenue, balance_reference_date = nil, share_reference_date = nil)
    self.calculate_own_value attr, balance_reference_date
    self.calculate_indirect_value attr, balance_reference_date, share_reference_date
    self.send "total_#{attr}=", self.send("own_#{attr}") + self.send("indirect_#{attr}")
    self.save
  end

  def cgc=(value)
    self['cgc'] = CgcHelper.format value
  end
  def add_cgc(cgc)
    return if cgc.blank?
    cgc = CgcHelper.format cgc
    self.cgc << cgc unless self.cgc.include?(cgc)
  end

  protected

  def assign_defaults
    self.name ||= self.formal_name
    self.cnpj_root ||= CgcHelper.extract_cnpj_root(self.cgc.first) if self.cnpj?
  end

  def normalize_fields
    self.name_n = self.name.filter_normalization
    self.formal_name_n = self.formal_name.filter_normalization if self.formal_name
  end

  def validate_cgc
    self.errors[:cgc] << 'Not a CPF or a CNPJ' unless CgcHelper.valid?(self.cgc.first)
  end

end

