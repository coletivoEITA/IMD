class Owner

  include MongoMapper::Document
  timestamps!

  key :name, String, :unique => true, :required => true
  key :country, String

  # for companies
  key :formal_name, String
  key :cgc, Array
  key :cnpj_root, String
  key :traded, Boolean
  key :classes, Array
  key :capital_type, String
  key :shares_quantity, Integer
  key :naics, Array
  key :sector, String
  key :stock_market, String
  key :stock_code, String
  key :members_count, Integer # nil means members not loaded

  key :own_revenue, Float, :default => 0
  key :indirect_revenue, Float, :default => 0
  key :total_revenue, Float, :default => 0

  key :own_patrimony, Float, :default => 0
  key :indirect_patrimony, Float, :default => 0
  key :total_patrimony, Float, :default => 0

  # downcase versions
  key :name_d, String
  key :formal_name_d, String

  #in case there is any data to access from www.asclaras.org later
  key :asclaras_id, Integer

  many :balances, :foreign_key => :company_id, :dependent => :destroy_all
  many :owners_shares, :class_name => 'Share', :foreign_key => :company_id, :dependent => :destroy_all
  many :owned_shares, :class_name => 'Share', :foreign_key => :owner_id, :dependent => :destroy_all

  many :members, :class_name => 'CompanyMember', :foreign_key => :company_id, :dependent => :destroy_all
  many :members_of, :class_name => 'CompanyMember', :foreign_key => :member_id, :dependent => :destroy_all

  many :candidacies, :class_name => 'Candidacy', :foreign_key => :candidate_id

  many :donations_made, :class_name => 'Donation', :foreign_key => :grantor_id
  many :donations_received, :class_name => 'Donation', :foreign_key => :candidate_id

  validates_uniqueness_of :formal_name, :allow_nil => true
  validates_uniqueness_of :cgc, :allow_nil => true
  validates_uniqueness_of :cnpj_root, :allow_nil => true
  validates_inclusion_of :capital_type, :in => %w(private state), :allow_nil => true
  before_validation :assign_defaults
  before_save :assign_downcases
  validate :validate_cgc

  #TODO:implement
  def donations_by_party_candidate(party=nil,candidate_name=nil,candidate_id_asclaras=nil)

  end

  def self.find_or_create(cgc = nil, name = nil, formal_name = nil)
    name_d = name.downcase if name
    formal_name_d = formal_name.downcase if formal_name

    owner_by_cgc = owner_by_name = owner_by_formal_name = nil
    owner_by_cgc = self.find_by_cgc(cgc) if cgc
    owner_by_name = self.find_by_name_d(name_d) if name
    owner_by_formal_name = self.find_by_formal_name_d(formal_name_d) if formal_name
    owner = owner_by_cgc || owner_by_name || owner_by_formal_name || self.new

    owner.add_cgc(cgc)
    owner.name ||= name
    owner.formal_name ||= formal_name
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

  def value(attr)
    return 0 if self.balances.first.nil?
    self.balances.first.value(attr)
  end

  def owned_shares_by_type(share_type = :on)
    case share_type
    when :on
      self.owned_shares.on.all
    when :pn
      self.owned_shares.pn.all
    else
      self.owned_shares.all
    end
  end

  # return the share/owner that controls this company
  def controller_share
    self.owners_shares.on.order(:percentage.desc).first
  end
  def controller_owner
    share = controller_share
    share.owner if share
  end

  def controlled_companies(share_type = :on)
    def __recursion(company, share_type = :on, visited = [])
      company.owned_shares_by_type(share_type).each do |owned_share|
        company = owned_share.company
        next if visited.include? company
        visited << company
        __recursion(company, share_type = :on, visited)
      end
      visited
    end

    visited = []
    __recursion(self, share_type, visited)
    visited
  end

  def calculate_own_value(attr)
    v = value(attr)
    self.send "own_#{attr}=", v
    self.save
    v
  end
  def calculate_indirect_value(attr, share_type = :on)
    def __recursion(company, attr = :revenue, share_type = :on, visited = [])
      company.owned_shares_by_type(share_type).inject(0) do |sum, owned_share|
        company = owned_share.company
        if visited.include? company
          0
        else
          visited << company

          total_value = company.send("total_#{attr}")
          if total_value.zero?
            own_value = company.send("own_#{attr}")
            own_value = company.calculate_own_value(attr)

            indirect_value = company.send("indirect_#{attr}")
            if indirect_value.zero?
              indirect_value = __recursion(company, attr, share_type, visited)
              # cache value
              company.send("indirect_#{attr}=", indirect_value)
            end

            total_value = own_value + indirect_value
            # cache value
            company.send("total_#{attr}=", total_value)
            company.save
          end

          sum + (owned_share.percentage/100) * total_value
        end
      end
    end

    v = __recursion(self, attr, share_type, [self])
    self.send "indirect_#{attr}=", v
    self.save
    v
  end

  def calculate_value(attr = :revenue, share_type = :on)
    self.calculate_own_value(attr)
    self.calculate_indirect_value(attr, share_type)
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

  def assign_downcases
    self.name_d = self.name.downcase
    self.formal_name_d = self.formal_name.downcase if self.formal_name
  end

  def validate_cgc
    self.errors[:cgc] << 'Not a CPF or a CNPJ' unless CgcHelper.valid?(self.cgc.first)
  end

end

