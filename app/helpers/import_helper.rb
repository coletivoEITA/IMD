# coding: UTF-8

module ImportHelper

  def self.clear_db
    Owner.destroy_all
    Share.destroy_all
    Balance.destroy_all
    Candidacy.destroy_all
    Donation.destroy_all    
    CompanyMember.destroy_all
	Grantor.destroy_all
    #NameEquivalence.destroy_all
  end

  def self.import_name_equivalences
    NameEquivalence.destroy_all
    csv = CSV.table 'db/name_equivalences.csv', :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first
      synonymous = row.values_at(1).first
      source = row.values_at(2).first

      ne = NameEquivalence.first_or_create :name => name, :synonymous => synonymous, :source => source
    end
  end

  def self.import_cvm_multiple_download
    url = 'https://WWW.RAD.CVM.GOV.BR/DOWNLOAD/SolicitaDownload.asp'

    m = Mechanize.new
    m.verify_mode = 0

    page = m.post url, {'txtLogin' => '397dwl0000257', 'txtSenha' => 'outubro12',
     'txtData' => '31/12/2012', 'txtHora' => '00:00', 'txtDocumento' => 'TODOS'}

    pp page.content
  end

  def self.import_cvm
    root_url = 'http://cvmweb.cvm.gov.br/SWB/Sistemas/SCW/CPublica/CiaAb/FormBuscaCiaAbOrdAlf.aspx'
    letter_url = 'http://cvmweb.cvm.gov.br/SWB/Sistemas/SCW/CPublica/CiaAb/FormBuscaCiaAbOrdAlf.aspx?LetraInicial=A'
    ian_url = 'http://siteempresas.bovespa.com.br/consbov/ExibeTodosDocumentosCVM.asp?CCVM=16802&CNPJ=02.288.752/0001-25&TipoDoc=C&QtLinks=3'
    m = Mechanize.new

    page = m.post ian_url, {'hdnCategoria' => 'IDI3 ', 'hdnPagina' => '', 'FechaI' => '', 'FechaV' => ''}
    page.content

    #m.get root_url
    #m.get letter_url
    #href = "javascript:__doPostBack('dlCiasCdCVM$_ctl1$Linkbutton1','')"
    #href =~ /__doPostBack\('(.+)'.+'(.+)'\)/
    #m.post letter_url, {'__EVENTTARGET' => $1, '__EVENTARGUMENT' => $2}
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

      share_class = 'ON' if share_class == 'Ord'

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

        value = 'ON' if field == :classes and value == 'Ord'

        # jump preprocessed
        next if ['cgc', 'name'].include?(field)

        # create balance and share if this is their first field
        if field == 'balance_months'
          # here we finished getting company data
          company.save!
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

  def self.import_receita_company_info(options = {})

    def self.get_page(cnpj)
      m = Mechanize.new
      url_host = "http://www.receita.fazenda.gov.br"
      url = "#{url_host}/PessoaJuridica/CNPJ/cnpjreva/Cnpjreva_Solicitacao2.asp?cnpj=%{cnpj}"

      page = m.get url % {:cnpj => cnpj}

      captcha_path = page.parser.css('#imgcaptcha')[0].attr('src')
      captcha_img = m.get("#{url_host}#{captcha_path}").content.read
      captcha_code = CaptchaHelper.open_and_type captcha_img

      form = page.forms.first
      form.action = 'valida.asp'

      captcha_input = form.fields.select{ |f| f.name == 'captcha' }.first
      captcha_input.value = captcha_code

      page = form.submit
    end

    def self.parse_page(cnpj, page)
      attr_map = {
        'NOME EMPRESARIAL' => :formal_name,
        #'TÍTULO DO ESTABELECIMENTO (NOME DE FANTASIA)' => :company_name,
        'DATA DE ABERTURA' => proc{ |o, v| o.open_date = DateHelper.date_from_brazil(v) },
        #'CÓDIGO E DESCRIÇÃO DA ATIVIDADE ECONÔMICA PRINCIPAL' =>
        #'CÓDIGO E DESCRIÇÃO DAS ATIVIDADES ECONÔMICAS SECUNDÁRIAS' =>
        'CÓDIGO E DESCRIÇÃO DA NATUREZA JURÍDICA' => :legal_nature,
        #'LOGRADOURO' =>
        #'NÚMERO' =>
        #'COMPLEMENTO' =>
        #'CEP' =>
        #'BAIRRO/DISTRITO' =>
        #'MUNICÍPIO' =>
        #'UF' =>
        #'SITUAÇÃO CADASTRAL' =>
        #'DATA DA SITUAÇÃO CADASTRAL' =>
      }

      owner = Owner.first_or_new 'Receita', :cgc => cnpj
      attr_map.each do |field_name, attr|
        field = page.parser.css("font:contains('#{field_name}')")[0]
        raise "Can't find field #{field_name}" if field.nil?
        value = field.parent.css('font')[1].text.squish

        if attr.is_a?(Proc)
          attr.call(owner, value)
        else
          owner.send("#{attr}=", value)
        end
      end
      owner.save!
      pp owner
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
      captcha_code = CaptchaHelper.open_and_type captcha_img

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
      formal_name = page.parser.css("td[valign=center] font[size='3']")[1].text.squish

      company = Owner.first_or_new 'Receita', :cgc => cnpj, :formal_name => formal_name
      pp company
      company.save!

      page.parser.css('table[bordercolor=LightGrey]').each do |table|
        attributes = {}

        table.css('table td font').each do |font|
          field = font.children[0].text.squish
          content = font.children[1].text.squish
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

          Thread.join_all if page == pages
          while queue.size > 0
            item = queue.pop
            process_company year, reference_date, key, dolar_value, item[1], item[2]
          end
        end
      end
    end
  end

  def self.import_valor(file, reference_date)
    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      ranking_position = row.values_at(0).first
      name = row.values_at(2).first
      state = row.values_at(3).first
      sector = row.values_at(4).first
      revenue = row.values_at(5).first

      owner = Owner.first_or_new 'Valor', :name => name
      owner.state = state
      owner.sector = sector
      owner.valor_ranking_position = ranking_position
      owner.save!

      balance = Balance.first_or_new(:company_id => owner.id, :source => "Valor",
                                     :currency => 'Real', :reference_date => reference_date)
      balance.revenue = revenue.to_f * 1000000
      balance.save!
    end
  end

  def self.import_asclaras_grantor_by_range(options = {})
    url_home = 'http://asclaras.org.br'
    url_grantor = "#{url_home}/@doador.php?doador=%{grantor_id}&ano=%{year}"
    m = Mechanize.new
    queue = Queue.new
	#range = Range.new(2755490,3499999,false)
	range_begin_2010 = 3714508
	range_end_2010 = 3879490
	year = 2010
	finished = false

    Thread.new do	
      mutex = Mutex.new           	 
      begin
        Thread.join_to_limit 3, [Thread.main]		  
		Thread.new do
		  finished = true if range_begin_2010 > range_end_2010
		  pp '----------------------------'		
		  page = m.get(url_grantor % {:grantor_id => range_begin_2010, :year => year})
		  queue << [page, range_begin_2010, year]		
		  range_begin_2010 = range_begin_2010 + 1				
		end
	  end while !finished
	
      Thread.join_all [Thread.main]
	  finished = true	
	end

    # queue processing
    while !finished
      if queue.empty?
        sleep 1
        next
      end

      item = queue.pop
	  import_asclaras_grantor item[0], item[1], item[2]

	  pp "grantor: %{grantor_id} year: %{year}" % {:grantor_id => item[1], :year => item[2]}
      pp '============================'     
    end
  end

  def self.import_asclaras_grantor(page, grantor_id, year)
    span = page.parser.css('span.destaque')[0]
	grantor_name = span.children[0].text	
	#TODO:refactore - find a way to group cgc
    grantor_cgc = []
    page.parser.css('tr#aba102 td.conteudo table tr').each do |tr|
	  data = tr.search('td') 
	  next if data.count != 2
	  name, cgc = data[0].text, data[1].text

      owner = Owner.first_or_new 'àsclaras', :cgc => cgc, :name => name
      owner.save!

	  grantor = Grantor.first_or_new :asclaras_id => grantor_id, :owner_id => owner.id, :year => year
      grantor.save!
    end
  end


  def self.import_asclaras(options = {})
    url_home = 'http://asclaras.org.br'
    # asclaras.org live on 3 out 2012
    url_candidacy = "#{url_home}/partes/index/@candidatos_frame.php?CAoffset=%{offset}&ano=%{year}&estado=%{state}&municipio=%{city}"
    url_donation = "#{url_home}/@candidato.php?CACodigo=%{candidate_id}&cargo=%{role_id}&ano=%{year}"
    url_grantor = "#{url_home}/@doador.php?doador=%{grantor_id}&ano=%{year}"

    m = Mechanize.new
    queue = Queue.new
    finished = false
    years = options[:year] ? [options[:year]] : [2002, 2004, 2006, 2008, 2010]
    #State = RJ = 18	... Todos -1
    state = options[:state] || -1
    #City = Rio de Janeiro = 3662 ... Todos -1
    city = options[:city] || -1

    if candidate_id = options[:candidate_id] and role_id = options[:role_id]
      year = years.first
      page = m.get(url_donation % {:candidate_id => candidate_id, :role_id => role_id, :year => year})
      import_asclaras_candidate page, year, {:asclaras_id => options[:candidate_id]}
      return
    end

    Thread.new do
      years.each do |year|
        offset = options[:offset] || 0
        mutex = Mutex.new
        year_finished = false

        begin
          Thread.join_to_limit 3, [Thread.main]
          Thread.new do
            o = nil
            mutex.synchronize do
              o = offset
              offset += 10
            end

            page = m.get(url_candidacy % {:offset => o, :year => year, :state => state, :city => city})
            links = page.links
            year_finished = true if links.count == 0

            pp '----------------------------'
            pp "offset: #{o}"

            #Get all link on a page as a Mechanize.Page.Link object
            page.parser.css('tr').each do |tr|
              tds = tr.css('td.linhas1') + tr.css('td.linhas2')
              next if tds.size == 0

              link = tds[0].css('a')[0]
              next unless link and link.attr('href') =~ /CACodigo=(.+)&cargo=(.+)/

              data = {}
              data[:asclaras_id] = $1.to_i
              data[:role_id] = $2.to_i
              data[:name] = link.text.squish
              data[:role] = tds[1].text.squish
              city_state = tds[2].text.squish
              if city_state.size == 2
                data[:state] = city_state
              else
                data[:city] = city_state.split('/')[0]
                data[:state] = city_state.split('/')[1]
              end
              data[:party] = tds[3].text.squish
              data[:votes] = tds[4].text.squish.gsub('.', '').to_i
              data[:status] = tds[7].text.squish

              page = m.get(url_donation % {:candidate_id => data[:asclaras_id], :role_id => data[:role_id], :year => year})
              queue << [page, year, data]
            end
          end

        end while !year_finished
      end

      Thread.join_all [Thread.main]
      finished = true
    end

    # queue processing
    while !finished
      if queue.empty?
        sleep 1
        next
      end

      item = queue.pop

      pp '============================'
      pp "candidato #{item[2][:asclaras_id]} #{item[2][:name]}"

      import_asclaras_candidate item[0], item[1], item[2]
    end
  end


# due to asclaras html design changes this method is depreciated
  def self.import_asclaras_candidate(page, year, data = {})
    if data[:name].nil?
      title = page.parser.css('td.tituloI')[0]
      return if title.nil?
      data[:name] = title.text
    end

    #In case there is owner referenced by owner_name get it's object, case not create a new one
    candidate = Owner.first_or_new 'àsclaras', :name => data[:name]
    candidate.save!

    #In case there is candidacy referenced by candidate get it's object
    candidacy = Candidacy.first_or_new(:year => year, :candidate_id => candidate.id, :asclaras_id => data[:asclaras_id])
    #In case not create a new one based on candidate_Data parsed  by Mechanize
    if candidacy.new_record?
      data.delete :role_id
      data[:status] = Candidacy::Status[data[:status]]
      candidacy.attributes = data
      candidacy.save!
    end

    # donations can be validated as unique,
    # they may even repeat, so we need to clean before load
    candidacy.donations.destroy_all

    page.parser.css('table script').each do |script|
      next unless script.text =~ /ids_(.+) .+Array\((.+)\).+Array\((.+)\).+Array\((.+)\).+Array\((.+)\)/
      type = $1 == 'diretas' ? 'direct' : 'committee'
      data = JSON.parse("[#{$2}]").zip JSON.parse("[#{$3}]"), JSON.parse("[#{$4}]"), JSON.parse("[#{$5}]")

      data.each do |donation|
        asclaras_id, name, cgc = donation[0], donation[1], donation[2]
        value = donation[3].gsub(".","").gsub(",",".").to_f

        grantor = Owner.first_or_new 'àsclaras', :cgc => cgc, :name => name, :asclaras_id => asclaras_id
        grantor.save!

        donation = Donation.create! :candidacy => candidacy, :grantor => grantor,
          :value => value, :type => type
      end
    end
  end

  def self.import_legal_nature_csv(file)
    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first
      formal_name = row.values_at(1).first
      cnpj = row.values_at(2).first
      legal_nature = row.values_at(3).first

      owner = Owner.first_or_new nil, :name => name
      pp owner
      owner.formal_name = formal_name unless formal_name.blank?
      owner.add_cgc cnpj
      owner.legal_nature = legal_nature
      owner.save!
    end
  end

end
