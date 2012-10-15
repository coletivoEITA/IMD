# coding: UTF-8

class Owner

  include MongoMapper::Document
  timestamps!

  key :name, String, :required => :true
  key :source, String, :required => :true

  # companies
  key :formal_name, String
  key :stock_name, String
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
  key :cvm_id, Integer
  key :classes, Array
  key :traded, Boolean
  key :stock_market, String
  key :stock_code, String
  key :shares_quantity, Hash # {'class' => 'quantity'}
  # extra info
  key :open_date, Time
  key :legal_nature, String

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

  key :valor_ranking_position, Integer

  # normalized versions
  key :name_n, String
  key :formal_name_n, String

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

    exact_match = self.first(attributes)

    attributes[:name], name = NameEquivalence.replace source, name
    attributes[:formal_name], formal_name = NameEquivalence.replace source, formal_name
    name_n = name.filter_normalization unless name.blank?
    formal_name_n = formal_name.filter_normalization unless formal_name.blank?

    exact_match ||= self.first(attributes)
    owner_by_cgc = owner_by_name = owner_by_formal_name = nil
    owner_by_cgc = self.find_by_cgc(cgc) unless cgc.blank?
    owner_by_name = self.find_by_name_n(name_n) unless name.blank?
    owner_by_formal_name = self.find_by_formal_name_n(formal_name_n) unless formal_name.blank?
    owner = exact_match || owner_by_cgc || owner_by_name || owner_by_formal_name || self.new

    owner.source ||= source
    owner.add_cgc(cgc) unless cgc.blank?
    attributes.each do |attr, value|
      next if attr.to_s == 'cgc'
      owner.send("#{attr}=", owner.send(attr) || value)
    end
    owner
  end

  def self.find_by_cgc(cgc)
    return nil if cgc.blank?
    cgc = CgcHelper.parse cgc
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

  def balance_with_value(attr, reference_date = nil)
    scoped = self.balances.with_reference_date(reference_date)
    balance = nil
    # get balance value in the following preference order
    ['Economatica', 'Valor'].each do |source|
      balance = scoped.where(:source => source).first
      next if balance.nil?

      break if !balance.value(attr).zero?
      balance = nil
    end
    balance
  end

  def value(attr, reference_date = nil)
    balance = balance_with_value attr, reference_date
    return 0 if balance.nil?
    balance.send(attr)
  end

  def indirect_parcial_controlled_companies(share_reference_date = nil)

    def __recursion(company, percentage, share_reference_date, visited = [])
      company.owned_shares.on.greatest.with_reference_date(share_reference_date).map do |owned_share|
        owned_company = owned_share.company
        next if owned_share.percentage.nil?

        next if visited.include? owned_company
        visited << owned_company

        p = percentage ? (owned_share.percentage*percentage)/100 : owned_share.percentage
        owned = __recursion(owned_company, p, share_reference_date, visited).compact
        if owned.empty?
          next if company == visited.first or owned_share.control?
          "#{owned_company.name} (#{owned_share.percentage.c}%, final=#{p.c}%)"
        else
          owned = owned.join("\n- ")
          "#{owned_company.name} => {\n- #{owned}}"
        end
      end
    end

    __recursion(self, nil, share_reference_date, [self]).flatten.compact
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
                    visited = [], fully_controlled = [])

      company.owned_shares.on.with_reference_date(share_reference_date).inject(0) do |sum, owned_share|
        owned_company = owned_share.company

        next sum if owned_share.percentage.nil?

        # company controls owned_company? (is percentage bigger than 50%?)
        is_controller = owned_share.control?
        fully_controlled << owned_company if is_controller

        # company has parcial controll of owned_company,
        # but owned_company is fully controlled by another company,
        # so we set wij = 0
        next sum if not is_controller and fully_controlled.include?(owned_company)

        next sum if visited.include? owned_company
        visited << owned_company

        total_value = owned_company.send("total_#{attr}")
        if total_value.zero?
          own_value = owned_company.send("own_#{attr}")
          if own_value.zero?
            own_value = owned_company.calculate_own_value(attr, balance_reference_date)
          end

          indirect_value = owned_company.send("indirect_#{attr}")
          if indirect_value.zero?
            indirect_value = __recursion owned_company, attr, balance_reference_date, share_reference_date, visited, fully_controlled
            # cache value
            owned_company.send("indirect_#{attr}=", indirect_value)
          end

          total_value = own_value + indirect_value
          # cache value
          owned_company.send("total_#{attr}=", total_value)
          owned_company.save
        end

        w = is_controller ? 1 : owned_share.percentage/100
        x = w * total_value

        sum + x
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
    v = self.send "total_#{attr}=", self.send("own_#{attr}") + self.send("indirect_#{attr}")
    self.save
    v
  end

  def cgc=(value)
    self['cgc'] = CgcHelper.parse value
  end
  def add_cgc(cgc)
    return if cgc.blank?
    cgc = CgcHelper.parse cgc
    self.cgc << cgc unless self.cgc.include?(cgc)
  end

  def set_value(attr, value)
    key = Owner.keys[attr.to_s]
    if attr.is_a?(Proc)
      attr.call self, value
    elsif key and key.type == Array
      old_value = self.send attr
      old_value << value unless old_value.include?(value)
    else
      self.send("#{attr}=", value)
    end
  end

  protected

  def assign_defaults
    self.name ||= NameEquivalence.replace(self.source, self.formal_name || self.stock_name)
    self.cnpj_root ||= CgcHelper.extract_cnpj_root(self.cgc.first) if self.cnpj?
  end

  def normalize_fields
    self.name_n = self.name.filter_normalization
    self.formal_name_n = self.formal_name.filter_normalization if self.formal_name
    self.stock_name = self.stock_name.upcase if self.stock_name
  end

  def validate_cgc
    self.errors[:cgc] << 'Not a CPF or a CNPJ' unless CgcHelper.valid?(self.cgc.first)
  end

end

