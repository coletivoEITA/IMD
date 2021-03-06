# coding: UTF-8

class Owner

  include MongoMapper::Document
  timestamps!

  NameFields = [:name, :formal_name, :stock_name]

  key :name, Set, :required => :true
  key :source, String, :required => :true
  key :type, String

  # companies
  key :formal_name, Set
  key :cgc, Set
  key :cnpj_root, String
  key :capital_type, String
  # group
  #key :group_id, ObjectId
  #belongs_to :group, :class_name => 'OwnerGroup'
  # company categorization
  key :naics, Set
  key :activity, String
  key :economatica_activity, String
  key :main_activity, String
  # company stock info
  key :cvm_id, Integer
  key :classes, Set
  key :traded, Boolean
  key :stock_name, Set
  key :stock_market, Set
  key :stock_code, Set
  key :stock_code_base, String
  key :stock_country, String
  key :shares_major_nationality, String
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

  key :sum_percentages_squares, Float

  key :source_detail, String

  # external ids
  key :econoinfo_ce, String

  # normalized versions
  NameFields.each do |field|
    key "#{field}_n", Set
  end

  # preference order of sources to use
  BalanceSources = ['Economatica', 'EconoInfo', 'Valor']

  many :balances, :foreign_key => :company_id, :dependent => :destroy_all

  many :owners_shares, :class_name => 'Share', :foreign_key => :company_id, :dependent => :destroy_all
  many :owned_shares, :class_name => 'Share', :foreign_key => :owner_id, :dependent => :destroy_all

  many :members, :class_name => 'CompanyMember', :foreign_key => :company_id, :dependent => :destroy_all
  many :members_of, :class_name => 'CompanyMember', :foreign_key => :member_id, :dependent => :destroy_all

  many :candidacies, :class_name => 'Candidacy', :foreign_key => :candidate_id, :dependent => :destroy_all

  many :donations_made, :class_name => 'Donation', :foreign_key => :grantor_id, :dependent => :destroy_all
  many :donations_received, :class_name => 'Donation', :foreign_key => :candidate_id, :dependent => :destroy_all

  NameFields.each do |field|
    validates_uniqueness_of field, :allow_nil => (field != :name)
  end
  validates_uniqueness_of :cgc, :allow_nil => true
  validates_uniqueness_of :cnpj_root, :allow_nil => true
  validate :validate_cgc

  before_validation :assign_defaults
  before_save :normalize_fields

  def self.first_or_new source, attributes = {}
    #equivalent = self.find_equivalent source, attributes

    exact_match = self.first attributes
    owner = exact_match || self.new
    owner.source ||= source
    attributes.each{ |attr, value| owner.set_value attr, value }

    # uncomment to print when new owners are created
    #puts "--- New owner #{name} ---" if owner.new_record?

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

  def self.find_equivalent source, attributes = {}
    by_cgc = by_stock_code = nil
    cgc, stock_code = attributes[:cgc], attributes[:stock_code]

    by_cgc = self.find_by_cgc cgc unless cgc.blank?
    unless stock_code.blank?
      by_stock_code = self.find_by_stock_code(stock_code)
      base = StockCodeHelper.base stock_code
      by_stock_code ||= self.find_by_stock_code_base(base) if base
    end

    NameFields.each do |f|
      name = attributes[f]
      next if name.blank?
      # remove end punctuation
      name.sub! /[?!,;]?$/, ''
      # capitalize each word TODO: fix downcase to utf8
      #name = name.downcase.split(' ').each{ |word| word.capitalize! }.join(' ')
      attributes[f] = name
    end

    name = attributes[:name]
    name = Owner.process_name name, source, attributes.reject{ |k, v| !NameFields.include?(k) or k == :name or v.blank? }.values.first
    attributes[:name] = name
    name_match = self.find_by_name_attrs attributes

    #name_match = MergeHelper.owner by_cgc, name_match if (name_match and by_cgc) and name_match != by_cgc

    by_cgc || name_match || by_stock_code
  end

  def self.find_by_name_attrs(attributes)
    attributes.each do |field, name|
      next unless NameFields.include? field.to_sym
      next if name.blank?

      ret = self.first :$or => NameFields.map{ |k, v| {k => name} }
      name_n = name.name_normalization
      ret ||= self.first :$or => NameFields.map{ |k, v| {"#{k}_n" => name_n} }
      return ret if ret
    end
    nil
  end

  def company?
    !person?
  end
  def person?
    type == 'Pessoa' or self.cpf?
  end
  def cnpj?
    CgcHelper.cnpj? self.cgc.first
  end
  def cpf?
    CgcHelper.cpf? self.cgc.first
  end

  def balance_with_value(attr = :revenue, reference_date = $balance_reference_date)
    scoped = self.balances.latest.with_reference_year reference_date
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
    return 0.0 if balance.nil?
    balance.value attr
  end

  alias_method :orig_owned_shares, :owned_shares
  alias_method :orig_owners_shares, :owners_shares
  def owned_shares share_reference_date = $share_reference_date
    @owned_shares ||= self.orig_owned_shares.on.greatest.with_reference_date(share_reference_date)
  end
  def owners_shares share_reference_date = $share_reference_date
    @owners_shares ||= self.orig_owners_shares.on.greatest.with_reference_date(share_reference_date)
  end

  def calculate_sum_percentages_squares reference_date = $share_reference_date
    self.sum_percentages_squares = self.owners_shares(reference_date).inject(0) do |sum, s|
      next sum if s.percentage.nil?
      sum + s.percentage ** 2
    end
  end

  def controller_share reference_date = $share_reference_date
    s = self.owners_shares(reference_date).first
    s if s and s.control?
  end
  def controller reference_date = $share_reference_date
    s = self.controller_share(reference_date)
    s.owner if s
  end

  def controller? reference_date = $share_reference_date
    @is_controller ||= self.owned_shares(reference_date).select{ |s| s.control? }.count > 0
  end
  def controlled? reference_date = $share_reference_date
    @is_controlled ||= (controlled = self.controller(reference_date)) and controlled != $uniao
  end
  def eper? attr = :revenue, reference_date = $share_reference_date
    def __recursion company, attr, reference_date, route = Set.new
      company_value = self.send "total_#{attr}"
      company.owned_shares(reference_date).each do |owned_share|
        owned_company = owned_share.company

        pair = [company, owned_company]
        next if route.include? pair

        owned_company_value = owned_company.send "total_#{attr}"
        return true if owned_company_value > company_value and owned_company.controller? and !owned_company.controlled?
        __recursion owned_company, attr, reference_date, route+[pair]
      end
      false
    end

    __recursion self, attr, reference_date
  end

  def indirect_controllers reference_date = $share_reference_date
    def __recursion company, reference_date, participation = nil, route = Set.new
      company.owners_shares(reference_date).map do |owner_share|
        owner = owner_share.owner
        next if owner_share.percentage.nil?
        next if route.include? company

        i_part = owner_share.participation*100
        p = participation ? (i_part*participation)/100 : i_part
        owners = __recursion owner, reference_date, p, route+[company]

        li = "•• "
        sep = li*(route.size+1)
        part_text = "#{owner_share.percentage.c 1}%/#{i_part.c 1}%/#{p.c 1}%"
        title = "#{sep}#{owner.name.first} (#{part_text})"
        if owners.empty? then
          title
        else
          "#{title}\n#{owners.join "\n"}"
        end
      end.flatten.compact
    end

    __recursion self, reference_date
  end

  def activity_control_tree reference_date = $share_reference_date

    def __recursion company, activities, reference_date, percentage = nil, route = Set.new
      company.owned_shares(reference_date).each do |owned_share|
        owned_company = owned_share.company

        pair = [company, owned_company]
        next if route.include? pair

        p = if percentage and owned_share.percentage
              then (owned_share.percentage*percentage)/100 else owned_share.percentage end
        __recursion owned_company, activities, reference_date, p, route+[pair]
      end

      return if company.main_activity.blank?
      activities[company.main_activity] ||= 0.0
      activities[company.main_activity] += percentage if percentage
    end

    activities = {}
    __recursion self, activities, reference_date
    activities = activities.map do |activity, percentage|
      "#{activity} (#{percentage.c}#{'%' if percentage})"
    end
  end

  def indirect_parcial_controlled_companies reference_date = $share_reference_date

    def __recursion company, reference_date, control = nil, participation = nil, route = Set.new
      company.owned_shares(reference_date).map do |owned_share|
        owned_company = owned_share.company
        next if owned_share.percentage.nil?

        direct = route.size.zero?
        pair = [company, owned_company]
        next if route.include? pair

        i_part = owned_share.participation*100
        p = participation ? (i_part*participation)/100 : i_part
        control = control.nil? ? owned_share.control? : (control && owned_share.control?)
        owned = __recursion owned_company, reference_date, control, p, route+[pair]

        li = "•• "
        sep = li*(route.size+1)
        title = "#{sep}#{owned_company.name.first}"
        part_text = "#{owned_share.percentage.c 1}%/#{i_part.c 1}%"
        part_text += "/#{p.c 1}%" unless direct
        if owned.empty?
          next if control == true or direct
          "#{title} (#{part_text})"
        else
          "#{title} (#{part_text})\n#{owned.join "\n"}"
        end
      end.flatten.compact
    end

    __recursion self, reference_date
  end
  def indirect_total_controlled_companies reference_date = $share_reference_date

    def __recursion company, reference_date, route = Set.new
      company.owned_shares(reference_date).map do |owned_share|
        next unless owned_share.control?
        owned_company = owned_share.company

        direct = route.size.zero?
        pair = [company, owned_company]
        next if route.include? pair

        list = []
        list << "#{owned_company.name.first} (controlada por #{company.name.first})" unless direct
        list += __recursion owned_company, reference_date, route+[pair]

        list
      end.flatten.compact
    end

    __recursion self, reference_date
  end

  def calculate_own_value(attr = :revenue, balance_reference_date = $balance_reference_date)
    own_value = self.value attr, balance_reference_date
    self.send "own_#{attr}=", own_value
    self.save
    own_value
  end

  FormulaPrint = false # one of [:letter, :number, :route]

  def calculate_power attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date

    print "\nP#{self.name.first.downcase} = " if FormulaPrint

    def __recursion company, attr, balance_reference_date, share_reference_date, route = Set.new
      own_value = company.value attr, balance_reference_date

      print "V#{company.name.first.downcase}" if FormulaPrint == :letter
      print own_value.to_s if FormulaPrint == :number

      company.owned_shares(share_reference_date).inject(own_value) do |sum, owned_share|
        owned_company = owned_share.company

        next sum if owned_share.participation.nil?

        # company controls owned_company? (is participation bigger than 50%?)
        is_controller = owned_share.control?
        has_controller = owned_company.controller(share_reference_date)

        # company has parcial controll of owned_company,
        # but owned_company is fully controlled by another company,
        # so we set wij = 0
        next sum if not is_controller and has_controller

        pair = [company, owned_company]
        next sum if route.include? pair

        w = is_controller ? 1 : owned_share.participation

        puts (route.map{ |p| p.first.name.first } << company.name.first << owned_company.name.first).join(',') if FormulaPrint == :route
        print " + W#{company.name.first.downcase}#{owned_company.name.first.downcase} * ( " if FormulaPrint == :letter
        print " + #{w} * ( " if FormulaPrint == :number

        power = __recursion owned_company, attr, balance_reference_date, share_reference_date, route+[pair]
        x = w * power

        print " )" if FormulaPrint

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

  def cgc= value
    raise 'Use add_cgc instead'
  end
  def add_cgc cgc
    Array(cgc).each do |cgc|
      cgc = CgcHelper.parse cgc
      return if cgc.blank?
      # don't allow CGCs with different roots
      return if self.cgc.first and !cgc.starts_with?(CgcHelper.extract_cnpj_root(self.cgc.first))
      self.cgc << cgc
    end
  end

  def set_value(attr, value)
    attr = attr.to_s
    if attr == 'cgc'
      self.add_cgc value
    elsif attr.is_a?(Proc)
      attr.call self, value
    elsif key = self.class.keys[attr] and key.type == Set
      old_value = self.send attr
      Set.new(Array(value)).each{ |value| old_value << value }
    else
      self.send "#{attr}=", value
    end
  end

  def self.process_name name, source, alternative
    name = NameEquivalence.replace source, name
    name = name.remove_company_nature.squish unless name.blank?
    return name unless name.blank?
    name = NameEquivalence.replace source, alternative
  end

  protected

  def assign_defaults
    self.name += self.formal_name
    self.cnpj_root ||= CgcHelper.extract_cnpj_root(self.cgc.first) if self.cnpj?
    self.stock_code_base = StockCodeHelper.base(stock_code.first)
  end

  def normalize_fields
    NameFields.each do |field|
      names = self.send field
      next if names.blank?
      self.set_value "#{field}_n", names.map{ |name| name.name_normalization }
    end
  end

  def validate_cgc
    self.errors[:cgc] << 'Not a CPF or a CNPJ' unless CgcHelper.valid?(self.cgc.first)
  end

end

