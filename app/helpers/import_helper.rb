# coding: UTF-8

module ImportHelper

  def self.clear_db
    Owner.destroy_all
    Share.destroy_all
    Balance.destroy_all
    Candidacy.destroy_all
    Donation.destroy_all
    CompanyMember.destroy_all
  end

  EconomaticaCSVColumns = ActiveSupport::OrderedHash[
    'Nome', :name,
    'Classe', :classes,
    'CNPJ', :cgc,
    'Pais Sede', :country,
    'Ativo /|Cancelado', :traded,
    'ID da|empresa', nil,
    'Setor NAICS|ult disponiv', :naics,
    'Setor|Economática', :economatica_sector,
    'Tipo de Ativo', nil,
    'Bolsa', :stock_market,
    'Código', :stock_code,
    'ISIN', nil,
    /Meses|.+|no exercício|consolid:sim*/, :balance_months,
    /Ativo Tot|.+|em moeda orig|consolid:sim*/, :balance_total_active,
    /Patrim Liq|.+|em moeda orig|consolid:sim*/, :balance_patrimony,
    /Receita|.+|em moeda orig|no exercício|consolid:sim*/, :balance_revenue,
    /Lucro Bruto|.+|em moeda orig|no exercício|consolid:sim*/, :balance_gross_profit,
    /Lucro Liq|.+|em moeda orig|no exercício|consolid:sim*/, :balance_net_profit,
    /Moeda dos|Balanços/, :balance_currency,
    /Qtd Ações|Outstanding|da empresa|.+/, :shares_quantity,
    /LPA|.+|em moeda orig|de 12 meses|consolid:sim*|ajust p\/ prov/, nil,
    /VPA|.+|em moeda orig|consolid:sim*|ajust p\/ prov/, nil,
    /Vendas\/Acao|.+|em moeda orig|de 12 meses|consolid:sim*|ajust p\/ prov/, nil,
    /Divid por Ação|.+|1 anos|em moeda orig/, nil,
    /Div Yld (fim)|.+|no Ano|em moeda orig/, nil,
    /Div Yld (inic)|.+|1 anos|em moeda orig/,nil,
    /PrinAcion|.+|1.Maior|Sem Voto/, :share_PN_01_name,
    /AcPossuid|.+|1.Maior|Sem Voto/, :share_PN_01_quantity,
    /PrinAcion|.+|2.Maior|Sem Voto/, :share_PN_02_name,
    /AcPossuid|.+|2.Maior|Sem Voto/, :share_PN_02_quantity,
    /PrinAcion|.+|3.Maior|Sem Voto/, :share_PN_03_name,
    /AcPossuid|.+|3.Maior|Sem Voto/, :share_PN_03_quantity,
    /PrinAcion|.+|4.Maior|Sem Voto/, :share_PN_04_name,
    /AcPossuid|.+|4.Maior|Sem Voto/, :share_PN_04_quantity,
    /PrinAcion|.+|5.Maior|Sem Voto/, :share_PN_05_name,
    /AcPossuid|.+|5.Maior|Sem Voto/, :share_PN_05_quantity,
    /PrinAcion|.+|6.Maior|Sem Voto/, :share_PN_06_name,
    /AcPossuid|.+|6.Maior|Sem Voto/, :share_PN_06_quantity,
    /PrinAcion|.+|7.Maior|Sem Voto/, :share_PN_07_name,
    /AcPossuid|.+|7.Maior|Sem Voto/, :share_PN_07_quantity,
    /PrinAcion|.+|8.Maior|Sem Voto/, :share_PN_08_name,
    /AcPossuid|.+|8.Maior|Sem Voto/, :share_PN_08_quantity,
    /PrinAcion|.+|9.Maior|Sem Voto/, :share_PN_09_name,
    /AcPossuid|.+|9.Maior|Sem Voto/, :share_PN_09_quantity,
    /PrinAcion|.+|10.Maior|Sem Voto/, :share_PN_10_name,
    /AcPossuid|.+|10.Maior|Sem Voto/, :share_PN_10_quantity,
    /PrinAcion|.+|1.Maior|Com Voto/, :share_ON_01_name,
    /AcPossuid|.+|1.Maior|Com Voto/, :share_ON_01_quantity,
    /PrinAcion|.+|2.Maior|Com Voto/, :share_ON_02_name,
    /AcPossuid|.+|2.Maior|Com Voto/, :share_ON_02_quantity,
    /PrinAcion|.+|3.Maior|Com Voto/, :share_ON_03_name,
    /AcPossuid|.+|3.Maior|Com Voto/, :share_ON_03_quantity,
    /PrinAcion|.+|4.Maior|Com Voto/, :share_ON_04_name,
    /AcPossuid|.+|4.Maior|Com Voto/, :share_ON_04_quantity,
    /PrinAcion|.+|5.Maior|Com Voto/, :share_ON_05_name,
    /AcPossuid|.+|5.Maior|Com Voto/, :share_ON_05_quantity,
    /PrinAcion|.+|6.Maior|Com Voto/, :share_ON_06_name,
    /AcPossuid|.+|6.Maior|Com Voto/, :share_ON_06_quantity,
    /PrinAcion|.+|7.Maior|Com Voto/, :share_ON_07_name,
    /AcPossuid|.+|7.Maior|Com Voto/, :share_ON_07_quantity,
    /PrinAcion|.+|8.Maior|Com Voto/, :share_ON_08_name,
    /AcPossuid|.+|8.Maior|Com Voto/, :share_ON_08_quantity,
    /PrinAcion|.+|9.Maior|Com Voto/, :share_ON_09_name,
    /AcPossuid|.+|9.Maior|Com Voto/, :share_ON_09_quantity,
    /PrinAcion|.+|10.Maior|Com Voto/, :share_ON_10_name,
    /AcPossuid|.+|10.Maior|Com Voto/, :share_ON_10_quantity,
  ]
  def self.header_to_field(header)
    field = EconomaticaCSVColumns[header]
    if field.nil?
      EconomaticaCSVColumns.each do |regexp, f|
        next unless regexp.is_a(Regexp)
        if header =~ regexp
          field = f
          break
        end
      end
    end
    field
  end
  def self.column_index_to_field(column_index)
    EconomaticaCSVColumns.values[column_index]
  end

  def self.import_economatica_csv(file, reference_date)
    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first
      share_class = row.values_at(1).first
      cnpj = row.values_at(2).first
      country = row.values_at(3).first

      next if country != 'BR' # only brazilian companies
      next if cnpj == '-'

      cnpj = cnpj.to_i
      cnpj = cnpj.zero? ? nil : ('%014d' % cnpj) # fix CNPJ format

      company = Owner.first_or_new 'Economatica', :cgc => cnpj, :name => name
      company.source = 'Economatica' # preferential
      balance = nil
      share = nil

      column_index = 0
      row.each do |header, value|
        field = column_index_to_field(column_index).to_s
        column_index += 1
        next if field.blank?

        # jump preprocessed
        next if ['cgc', 'name'].include?(field)

        # create balance and share if this is their first field
        if field == 'balance_months'
          balance.save if balance
          balance = Balance.first_or_new(:company_id => company.id, :source => "Economatica",
                                         :reference_date => reference_date)
        end
        if field =~ /share_(.+)_(.+)_name/
          share.save if share
          share = Share.first_or_new(:company_id => company.id, :source => "Economatica",
                                     :name => value, :reference_date => reference_date, :sclass => $1)
        end

        next if value.blank? or value == '-' or value == '0' or value == '0.0'

        if field.starts_with?('balance_')
          balance.send "#{$1}=", value if field =~ /balance_(.+)/
        elsif field.starts_with?('share_')
          share.send "#{$3}=", value if field =~ /share_(.+)_(.+)_(.+)/
        elsif field == 'traded'
          company.traded = value == 'ativo'
        elsif field == 'shares_quantity'
          company.shares_quantity[share_class] = value
        else
          old_value = company.send(field)
          if Owner.keys[field].type != Array
            company.send "#{field}=", value
          else
            old_value << value unless old_value.include?(value)
          end
        end

      end

      pp company
      company.save!
      balance.save! if balance
      share.save! if share and !share.name.blank? and !share.quantity.nil?
    end
  end

  def self.import_receita_companies_members(options = {})
    def self.get_page(cnpj)
      m = Mechanize.new
      referer = "http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/fcpj/link097.asp"
      url = "http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/CNPJConsul/consulta.asp"
      frame = "http://www.receita.fazenda.gov.br/pessoajuridica/cnpj/CNPJConsul/consulta_socios.asp"
      captcha = 'http://www.receita.fazenda.gov.br/Scripts/srf/img/srfimg.dll'

      page = m.post url, {'cnpj' => cnpj}, {'Referer' => referer}
      page = page.frames[1].click

      captcha_img = m.get(captcha).content.read
      captcha_path = '/tmp/captch_path.jpg'
      File.open(captcha_path, 'w'){ |f| f.write captcha_img }
      pid = -Process.fork do
        Process.setpgrp
        system "qiv #{captcha_path}"
        #system "jp2a #{captcha_path}"
      end

      print "Type captcha: "
      captcha_code = gets.split("\n").first
      Process.kill 9, pid

      form = page.forms.first
      captcha_input = form.fields.last
      captcha_input.value = captcha_code
      page = form.submit

      return nil if page.content.index('Acesso negado')
      page
    end

    def self.parse_page(cnpj, page)
      mapping = {
        'CPF/CNPJ:' => :cgc,
        'Nome/Nome Empresarial:' => :formal_name,
        'Entrada na Sociedade:' => :entrance_date,
        'Qualificação:' => :qualification,
        'Part. Capital Social:' => :participation,
      }
      formal_name = page.parser.css("td[valign=center] font[size='3']")[1].text.strip

      company = Owner.first_or_new 'Receita', :cgc => cnpj, :formal_name => formal_name
      pp company
      company.save!

      page.parser.css('table[bordercolor=LightGrey]').each do |table|
        attributes = {}

        table.css('table td font').each do |font|
          field = font.children[0].text.strip
          content = font.children[1].text.strip
          attributes[mapping[field]] = content
        end

        cgc = attributes[:cgc]
        if cgc == 'sócio estrangeiro'
          cgc = 'foreign'
        else
          cgc = cgc
        end
        formal_name = attributes[:formal_name]

        owner_member = Owner.first_or_new 'Receita', :cgc => cgc, :formal_name => formal_name
        member = CompanyMember.first_or_new(:company_id => company.id, :member_id => owner_member.id)
        member.company = company
        member.member = owner_member
        member.entrance_date = attributes[:entrance_date]
        member.qualification = attributes[:qualification]
        member.participation = attributes[:participation]

        company.members << member
        member.save!
        member.member.save!

        pp member
        pp member.member
      end

      # some companies has 0 members, so nil means not iterated
      company.members_count = company.members.count
      company.save!
    end

    def self.process_cnpj(cnpj)
      cnpj = CgcHelper.format cnpj
      page = nil
      loop do
        break if page = get_page(cnpj)
        puts 'Error while getting page, try again'
      end
      parse_page(cnpj, page)
    end

    if cnpj = options[:cnpj]
      process_cnpj(cnpj)
      return
    end

    # mark as cheched to FII companies which
    # tipycally has no members
    #Owner.each{ |o| next unless o.name_n.starts_with?('fii '); o.members_count = 0; o .save }

    Owner.each do |owner|
      next if owner.cgc.first.nil?
      next if !owner.cnpj?
      next if owner.members_count

      cnpj = owner.cgc.first

      # HTTP 500 error
      next if ['97837181000147', '08467115000100'].include?(cnpj)

      puts '==============================='
      pp owner

      process_cnpj(cnpj)
    end

  end


  def self.import_companies(*files)
    csvs = *files.map do |file|
      CSV.table file, :converters => nil
    end
    hash = {}
    csvs.each do |csv|
      csv.each_with_index do |row, i|
        formal_name = row.values_at(1).first
        cgc = row.values_at(0).first
        hash[formal_name] ||= []
        hash[formal_name] << cgc
      end
    end

    hash.each do |formal_name, cgc_list|
      next if formal_name.blank?

      owner = nil
      cgc_list.each do |cgc|
        owner = Owner.first_or_new 'MDIC', :cgc => cgc, :formal_name => formal_name
        break if owner
      end

      cgc_list.each{ |cgc| owner.add_cgc cgc }

      pp owner
      owner.save!
    end
  end

  def self.import_exame_maiores(dolar_value)

    def self.process_company(year, reference_date, key, dolar_value, tds, spans = nil)
      name = tds[3].text
      formal_name = tds[2].text
      cnpj = spans ? spans[6].text : nil

      owner = Owner.first_or_new 'Exame', :cgc => cnpj, :name => name, :formal_name => formal_name
      owner.sector = tds[4].text
      owner.capital_type = tds[5].text == 'Privada' ? 'private' : 'state'
      if spans
        owner.address = spans[2].text
        owner.city = spans[3].text
        owner.phone = spans[4].text
        owner.website = spans[5].text
        # FIXME: check if present
        #owner.group = OwnerGroup.first_or_create(:name => spans[8].text)
      end
      owner.save!
      pp owner

      balance = Balance.first_or_new(:company_id => owner.id, :source => "Exame",
                                     :currency => 'Real', :reference_date => reference_date)
      value = tds[7].text.gsub('.', '').gsub(',', '.').to_f * 1000000
      value *= dolar_value # convert from Dolar to Real
      balance.send "#{key}=", value
      balance.save!
      pp balance
    end

    url = "http://exame.abril.com.br/negocios/melhores-e-maiores/empresas/maiores/%{page}/%{year}/%{attr}"
    pages = 125
    years = [2011]
    attributes = {
      'vendas' => :revenue,
    }

    m = Mechanize.new
    queue = Queue.new

    years.each do |year|
      reference_date = Time.mktime(year).end_of_year.to_date.strftime('%Y-%m-%d')

      attributes.each_with_index do |(attr, key), i|
        (1..pages).each do |page|
          page = m.get(url % {:year => year, :attr => attr, :page => page})

          trs = page.parser.css 'table.table_mm_g tr[class*=row]'
          trs.each do |tr|
            Thread.new do # works with mechanize
              tds = tr.children.select{ |td| td.element? }

              if i == 0 # avoid fetching same data
                page = m.get tr.css('a')[0].attr('href')
                spans = page.parser.css('.box_empresa span.value')
              else
                spans = nil
              end

              queue << [Thread.current, tds, spans]
            end

          end

          Thread.list.each{ |t| t.join if t != Thread.current } if page == pages
          while queue.size > 0
            item = queue.pop
            Process.fork do
              process_company year, reference_date, key, dolar_value, item[1], item[2]
            end
          end
        end
      end
    end
  end

  def self.import_valor(file, reference_date)
    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(2).first
      state = row.values_at(3).first
      sector = row.values_at(4).first
      revenue = row.values_at(5).first

      owner = Owner.first_or_new 'Valor', :name => name
      owner.state = state
      owner.sector = sector
      owner.save!

      balance = Balance.first_or_new(:company_id => owner.id, :source => "Valor",
                                     :currency => 'Real', :reference_date => reference_date)
      balance.revenue = revenue.to_f * 1000000
      balance.save!
    end
  end

  def self.import_asclaras(options = {})
    url_home = 'http://asclaras.org.br'
	# asclaras.org live on 3 out 2012
    url_candidacy = "#{url_home}/partes/index/@candidatos_frame.php?CAoffset=%{offset}&ano=%{year}&estado=%{state}&municipio=%{city}"
    url_donation = "#{url_home}/@candidato.php?CACodigo=%{candidate_id}&cargo=%{role_id}&ano=%{year}"

    m = Mechanize.new
    years = options[:year] ? [options[:year]] : [2002, 2004, 2006, 2008, 2010]
	#State = RJ = 18	... Todos -1
	state = options[:state] || -1
  	#City = Rio de Janeiro = 3662 ... Todos -1
	city = options[:city] || -1

	cargos = {}
	cargos[-1] = 'Todos'
	cargos[1] = 'Presidente'
	cargos[2] = ''
	cargos[3] = 'Governador'
	cargos[4] = ''
	cargos[5] = 'Senador'
	cargos[6] = 'Deputado Federal'
	cargos[7] = 'Deputado Estadual'
	cargos[8] = 'Deputado Distrital'
	cargos[11] = 'Prefeito'
	cargos[13] = 'Vereador'

    years.each do |year|
      offset = options[:offset] || 0
      begin
        page = m.get(url_candidacy % {:offset => offset, :year => year, :state => state, :city => city})
        links = page.links			
        pp '----------------------------'
        pp "offset: #{offset}"
        #Get all link on a page as a Mechanize.Page.Link object
        links.each do |link|
          next unless link.href =~ /CACodigo=(.+)&cargo=(.+)/
       	  candidate_id_asclaras = $1
       	  role_id_asclaras = $2
	   	  pp '============================'
		  pp 'candidato ' + candidate_id_asclaras + ' ' + link.text
		  page = m.get(url_donation % {:candidate_id => candidate_id_asclaras, :role_id => role_id_asclaras, :year => year})
		  import_asclaras_donation(page, year, candidate_id_asclaras)
        end		
        offset += links.count
      end while links.count > 0
    end
  end
  #end method import_asclaras

  def self.import_asclaras_donation(page, year, candidate_id_asclaras)
    candidate_name = page.parser.css('td.tituloI')[0].text
    #In case there is owner referenced by owner_name get it's object, case not create a new one
    candidate = Owner.first_or_new 'àsclaras', :name => candidate_name
    candidate.save!
    #In case there is candidacy referenced by candidate get it's object
    candidacy = Candidacy.first_or_new(:year => year, :candidate_id => candidate.id, :source_id => candidate_id_asclaras)
    #In case not create a new one based on candidate_Data parsed  by Mechanize
    if candidacy.new_record?
      candidate_data = page.parser.css("table tr:nth-child(3) table th")
      candidacy.role = candidate_data[0].text.strip
      candidacy.party = candidate_data[1].text.strip
      #index to control data index to import
      index = 0
	  if "Presidente" == candidacy.role
        candidacy.state = "BR"
        index = 5      
      elsif ("Vereador" == candidacy.role) || ("Prefeito" == candidacy.role)
        uf = candidate_data[2].text().strip
        candidacy.city = uf.split("-")[0].strip
        candidacy.state = uf.split("-")[1].strip
        index = 6	   	
      elsif ("Senador" == candidacy.role) || ("Governador" == candidacy.role) || ("Deputado Federal" == candidacy.role) || ("Deputado Estadual" == candidacy.role) || ("Deputado Distrital" == candidacy.role)
        candidacy.city = ''
        candidacy.state = candidate_data[2].text().strip
        index = 6	 
	  end  			  
      if "Eleito" == candidate_data[index].text.strip
        candidacy.status = "elected"
      elsif "Não Eleito" == candidate_data[index].text.strip
        candidacy.status = "not_elected"
      elsif "Suplente" == candidate_data[index].text.strip
        candidacy.status = "substitute"
      end
      candidacy.save!
    end
	
	#loop to save all donation from this candidacy
	page.parser.css('#aba13 script').each do |script|
	  next unless script.text =~ /"(.+)".+"(.+)".+"(.+)".+"(.+)"/
	  grantor_id_asclaras = $1
	  grantor_name = $2
	  grantor_cgc = $3
	  value = $4.gsub(".","").gsub(",",".").to_f
	  grantor = Owner.first_or_new 'àsclaras', :cgc => grantor_cgc, :name => grantor_name, :source_id => grantor_id_asclaras
      grantor.save!
      donation = Donation.first_or_new :candidacy_id => candidacy.id, :grantor_id => grantor.id, :value => value
      donation.save!
	end	
  end
  #end method import_asclaras_donation
end
