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
  key :stock_market, Array
  key :stock_code, Array
  key :stock_code_base, String
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

  key :own_revenue, Float
  key :indirect_revenue, Float
  key :total_revenue, Float

  key :own_patrimony, Float
  key :indirect_patrimony, Float
  key :total_patrimony, Float

  key :valor_ranking_position, Integer

  key :source_detail, String

  # normalized versions
  key :name_n, String
  key :formal_name_n, String

  # preference order of sources to use
  BalanceSources = ['Economatica', 'Valor']

  many :balances, :foreign_key => :company_id, :dependent => :destroy_all

  many :owners_shares, :class_name => 'Share', :foreign_key => :company_id, :dependent => :destroy_all
  many :owned_shares, :class_name => 'Share', :foreign_key => :owner_id, :dependent => :destroy_all

  many :members, :class_name => 'CompanyMember', :foreign_key => :company_id, :dependent => :destroy_all
  many :members_of, :class_name => 'CompanyMember', :foreign_key => :member_id, :dependent => :destroy_all

  many :candidacies, :class_name => 'Candidacy', :foreign_key => :candidate_id, :dependent => :destroy_all

  many :donations_made, :class_name => 'Donation', :foreign_key => :grantor_id, :dependent => :destroy_all
  many :donations_received, :class_name => 'Donation', :foreign_key => :candidate_id, :dependent => :destroy_all

  validates_uniqueness_of :cgc, :allow_nil => true
  validates_uniqueness_of :cnpj_root, :allow_nil => true
  validates_uniqueness_of :name
  validates_uniqueness_of :formal_name, :allow_nil => true
  validates_uniqueness_of :stock_name, :allow_nil => true
  validates_inclusion_of :capital_type, :in => %w(private state), :allow_nil => true
  validate :validate_cgc

  before_validation :assign_defaults
  before_save :normalize_fields

  def self.first_or_new(source, attributes = {})
    by_cgc = by_name = by_formal_name = nil
    cgc, name = attributes[:cgc], attributes[:name]
    formal_name, stock_name = attributes[:formal_name], attributes[:stock_name]

    name = NameEquivalence.replace source, name
    # no name filled, get and replace from formal_name
    name = Owner.process_name name, source, formal_name || stock_name
    attributes[:name] = name

    exact_match = self.first(attributes)
    by_cgc = self.find_by_cgc(cgc) unless cgc.blank?

    unless name.blank?
      name_n = name.name_normalization
      by_name = self.first :name => name
      by_name ||= self.first :$or => [{:name_n => name_n}, {:formal_name_n => name_n}]
    end
    unless formal_name.blank?
      formal_name_n = formal_name.name_normalization
      by_formal_name = self.first :formal_name => formal_name
      by_formal_name ||= self.first :$or => [{:formal_name_n => formal_name_n}, {:name_n => formal_name_n}]
    end

    owner = exact_match || by_cgc || by_name || by_formal_name || self.new

    # uncomment to print when new owners are created
    #puts "--- New owner #{name} ---" if owner.new_record?

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

  def stock_code_base
    code = stock_code.first
    code =~ /([a-z]+)/i
    $1
  end

  def balance_with_value(attr = :revenue, reference_date = $balance_reference_date)
    scoped = self.balances.with_reference_date(reference_date)
    balance = nil
    # get balance value in the following preference order
    BalanceSources.each do |source|
      balance = scoped.where(:source => source).first
      next if balance.nil?

      break if !balance.value(attr).zero?
      balance = nil
    end
    balance
  end

  def value(attr = :revenue, reference_date = $balance_reference_date)
    balance = balance_with_value attr, reference_date
    return 0 if balance.nil?
    balance.send attr
  end

  def controller_share(reference_date = $share_reference_date)
    s = self.owners_shares.on.greatest.with_reference_date(reference_date).first
    s if s and s.control?
  end
  def controller(reference_date = $share_reference_date)
    s = self.controller_share(reference_date)
    s.owner if s
  end

  def indirect_parcial_controlled_companies(share_reference_date = $share_reference_date)

    def __recursion(company, percentage, control, share_reference_date, route = Set.new)
      company.owned_shares.on.greatest.with_reference_date(share_reference_date).map do |owned_share|
        owned_company = owned_share.company
        next if owned_share.percentage.nil?

        direct = route.size.zero?
        pair = [company, owned_company]
        next if route.include? pair

        p = percentage ? (owned_share.percentage*percentage)/100 : owned_share.percentage
        control = control.nil? ? owned_share.control? : (control && owned_share.control?)
        owned = __recursion owned_company, p, control, share_reference_date, route+[pair]

        participation = "#{owned_share.percentage.c}%, final=#{p.c}%"
        if owned.empty?
          next if control == true or direct
          "#{owned_company.name} (#{participation})"
        else
          sep = owned.count > 1 ? "\n#{'•• '*(route.size+1)}" : ''
          end_sep = owned.count > 1 ? "\n#{'•• '*(route.size)}}" : "}"
          owned = sep + owned.join(sep)
          partipation = direct ? '' : " (#{partipation})"
          "#{owned_company.name}#{participation} => {#{owned}#{end_sep}"
        end
      end.flatten.compact
    end

    __recursion self, nil, nil, share_reference_date
  end
  def indirect_total_controlled_companies(share_reference_date = $share_reference_date)

    def __recursion(company, share_reference_date, route = Set.new)
      company.owned_shares.on.greatest.with_reference_date(share_reference_date).map do |owned_share|
        next unless owned_share.control?
        owned_company = owned_share.company

        direct = route.size.zero?
        pair = [company, owned_company]
        next if route.include? pair

        list = []
        list << "#{owned_company.name} (controlada por #{company.name})" unless direct
        list += __recursion owned_company, share_reference_date, route+[pair]

        list
      end.flatten.compact
    end

    __recursion self, share_reference_date
  end

  def calculate_own_value(attr = :revenue, balance_reference_date = $balance_reference_date)
    own_value = self.value attr, balance_reference_date
    self.send "own_#{attr}=", own_value
    self.save
    own_value
  end

  def calculate_power attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date

    # uncomment to print formula
    #print "\nP#{self.name.downcase} = "

    def __recursion(company, attr, balance_reference_date, share_reference_date, route = Set.new)
      own_value = company.value attr, balance_reference_date

      # uncomment to print letter formula
      #print "V#{company.name.downcase}"
      # uncomment to print number formula
      #print own_value.to_s

      company.owned_shares.on.with_reference_date(share_reference_date).inject(own_value) do |sum, owned_share|
        owned_company = owned_share.company

        next sum if owned_share.percentage.nil?

        # company controls owned_company? (is percentage bigger than 50%?)
        is_controller = owned_share.control?
        has_controller = owned_company.controller(share_reference_date)

        # company has parcial controll of owned_company,
        # but owned_company is fully controlled by another company,
        # so we set wij = 0
        next sum if not is_controller and has_controller

        pair = [company, owned_company]
        next sum if route.include? pair

        w = is_controller ? 1 : owned_share.percentage/100

        # uncomment to print route
        #puts (route.map{ |p| p.first.name } << company.name << owned_company.name).join(',')
        # uncomment to print letter formula
        #print " + W#{company.name.downcase}#{owned_company.name.downcase} * ( "
        # uncomment to print number formula
        #print " + #{w} * ( "

        power = __recursion owned_company, attr, balance_reference_date, share_reference_date, route+[pair]
        x = w * power

        # uncomment to print formula
        #print " )"

        sum + x
      end
    end

    total_value = __recursion self, attr, balance_reference_date, share_reference_date
    self.send "total_#{attr}=", total_value
    self.save
    total_value
  end

  def calculate_values(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)
    own_value = self.calculate_own_value attr, balance_reference_date
    total_value = self.calculate_power attr, balance_reference_date, share_reference_date
    indirect_value = total_value - own_value
    self.send "indirect_#{attr}=", indirect_value
    self.save
    total_value
  end

  def cgc=(value)
    self['cgc'] = CgcHelper.parse value
  end
  def add_cgc(cgc)
    cgc = CgcHelper.parse cgc
    return if cgc.blank?
    self.cgc << cgc unless self.cgc.include?(cgc)
  end

  def set_value(attr, value)
    if attr.is_a?(Proc)
      attr.call self, value
    elsif key = Owner.keys[attr] and key.type == Array
      old_value = self.send attr
      old_value << value unless old_value.include?(value)
    else
      self.send("#{attr}=", value)
    end
  end

  def self.process_name name, source, alternative
    name = name.remove_company_nature.squish unless name.blank?
    return name unless name.blank?
    name = NameEquivalence.replace source, alternative
  end

  protected

  def assign_defaults
    self.cnpj_root ||= CgcHelper.extract_cnpj_root(self.cgc.first) if self.cnpj?
    self.stock_code_base = self.stock_code_base
  end

  def normalize_fields
    self.name_n = self.name.name_normalization
    self.formal_name_n = self.formal_name.name_normalization if self.formal_name
    self.stock_name = self.stock_name.upcase if self.stock_name
  end

  def validate_cgc
    self.errors[:cgc] << 'Not a CPF or a CNPJ' unless CgcHelper.valid?(self.cgc.first)
  end

end

