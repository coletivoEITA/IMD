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
    'Nome', :stock_name,
    'Classe', :classes,
    'CNPJ', :cgc,
    'Pais Sede', :country,
    'Ativo /|Cancelado', :traded,
    'ID da|empresa', :cvm_id,
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
        next unless regexp.is_a?(Regexp)
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
      stock_name = row.values_at(0).first
      share_class = row.values_at(1).first
      cnpj = row.values_at(2).first
      country = row.values_at(3).first

      next if country != 'BR' # only brazilian companies
      next if cnpj == '-'

      share_class = 'ON' if share_class == 'Ord'

      cnpj = cnpj.to_i
      cnpj = cnpj.zero? ? nil : ('%014d' % cnpj) # fix CNPJ format

      company = Owner.first_or_new 'Economatica', :cgc => cnpj, :stock_name => stock_name
      company.source = 'Economatica' # preferential
      balance = nil
      share = nil

      column_index = 0
      row.each do |header, value|
        field = column_index_to_field(column_index).to_s
        column_index += 1
        next if field.blank?

        value = 'ON' if field == :classes and value == 'Ord'
        value.squish!
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

        # jump nil
        next if value.blank? or value == '-' or value == '0' or value == '0.0'

        if field.starts_with?('balance_')
          balance.send "#{$1}=", value if balance and field =~ /balance_(.+)/
        elsif field.starts_with?('share_')
          share.send "#{$3}=", value if share and field =~ /share_(.+)_(.+)_(.+)/
        elsif field == 'traded'
          company.traded = value == 'ativo'
        elsif field == 'shares_quantity'
          company.shares_quantity[share_class] = value.to_i
        else
          company.set_value field, value
        end

      end

      pp company
      company.save!
      balance.save
      share.save
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

      company = Owner.first_or_new 'Receita', :cgc => cnpj
      attr_map.each do |field_name, attr|
        field = page.parser.css("font:contains('#{field_name}')")[0]
        raise "Can't find field #{field_name}" if field.nil?
        value = field.parent.css('font')[1].text.squish

        company.set_value attr, value
      end
      company.save!
      pp company
    end

    def self.process_cnpj(cnpj)
      cnpj = CgcHelper.parse cnpj
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
      cnpj = CgcHelper.parse cnpj
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

  def self.import_bovespa(options = {})
    Cache.enable
    m = Mechanize.new
    url = "http://www.bmfbovespa.com.br/cias-listadas/empresas-listadas/ResumoEmpresaPrincipal.aspx?codigoCvm=%{cvm_id}&idioma=pt-br"
    frame_url = "http://www.bmfbovespa.com.br/pt-br/mercados/acoes/empresas/ExecutaAcaoConsultaInfoEmp.asp?CodCVM=%{cvm_id}"
    source = 'Bovespa'

    attr_map = {
      'CNPJ' => proc{ |o, v| o.add_cgc v },
      'Nome de Pregão' => :stock_name,
      'Site' => :website,
    }

    cvm_id = options[:cvm_id]
    raise 'Please give a cvm code' if cvm_id.blank?

    page = m.get url % {:cvm_id => cvm_id}
    formal_name = page.parser.css('h1 span.label')[0].text.squish
    pp formal_name

    page = m.get frame_url % {:cvm_id => cvm_id}

    company = Owner.first_or_new source, :cvm_id => cvm_id, :formal_name => formal_name
    attr_map.each do |field_name, attr|
      field = page.parser.css("td.IdentificacaoDado:contains('#{field_name}')")[0]
      next if field.nil?
      value = field.parent.css('td')[1].text.squish

      company.set_value attr, value
    end
    company.save!
    pp company

    reference_date = options[:reference_date]
    if reference_date.nil?
      # TODO fetch from .obs2col
      raise 'give a reference date'
    end

    page.parser.css('#divPosicaoAcionaria .tabela tr').each do |tr|
      tds = tr.css('td')
      next if tds.size != 4
      name = tds[0].text.squish
      next if name == 'Total'
      on_percentage = tds[1].text.squish.gsub(',', '.').to_f
      pn_percentage = tds[2].text.squish.gsub(',', '.').to_f
      total_shares = tds[3].text.squish.gsub(',', '.').to_f

      unless on_percentage.zero?
        s = Share.first_or_new(:company_id => company.id, :name => name, :source => source,
                               :reference_date => reference_date, :sclass => 'ON')
        s.percentage = on_percentage
        s.save!
        pp s
      end
      unless pn_percentage.zero?
        s = Share.first_or_new(:company_id => company.id, :name => name, :source => source,
                               :reference_date => reference_date, :sclass => 'PN')
        s.percentage = pn_percentage
        s.save!
        pp s
      end
    end

    company
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

      company = Owner.first_or_new 'Exame', :cgc => cnpj, :name => name, :formal_name => formal_name
      company.sector = tds[4].text
      company.capital_type = tds[5].text == 'Privada' ? 'private' : 'state'
      if spans
        company.address = spans[2].text
        company.city = spans[3].text
        company.phone = spans[4].text
        company.website = spans[5].text
        # FIXME: check if present
        #company.group = OwnerGroup.first_or_create(:name => spans[8].text)
      end
      pp company
      company.save!

      balance = Balance.first_or_new(:company_id => company.id, :source => "Exame", :reference_date => reference_date)
      value = tds[7].text.gsub('.', '').gsub(',', '.').to_f * 1000000
      value *= dolar_value # convert from Dolar to Real
      balance.currency = 'Real'
      balance.send "#{key}=", value
      pp balance
      balance.save!
    end

    url = "http://exame.abril.com.br/negocios/melhores-e-maiores/empresas/maiores/%{page}/%{year}/%{attr}"
    pages = 125
    years = [2011]
    attributes = {
      'vendas' => :revenue,
    }

    Cache.enable
    m = Mechanize.new
    queue = Queue.new

    years.each do |year|
      reference_date = Time.mktime(year).end_of_year.at_beginning_of_day

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

  def self.import_valor_csv(file, reference_date)
    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      ranking_position = row.values_at(0).first
      name = row.values_at(2).first
      state = row.values_at(3).first
      sector = row.values_at(4).first
      revenue = row.values_at(5).first

      company = Owner.first_or_new 'Valor', :name => name
      company.state = state
      company.sector = sector
      company.valor_ranking_position = ranking_position
      company.save!

      balance = Balance.first_or_new(:company_id => company.id, :source => "Valor",
                                     :currency => 'Real', :reference_date => reference_date)
      balance.revenue = revenue.to_f * 1000000
      balance.save!
    end
  end

  def self.import_asclaras_grantor_locally()
    empty_donator = []
	file_path = '/home/caioformiga/workspace/EITA/IMD/db/wget/'
	dir = Dir.new(file_path)
	dir.each { |file_name|
	  if file_name != "." && file_name != ".." && file_name != 'asclaras_grantor.pl' && file_name != 'teste.pl'
	    html_file = file_path + file_name
	    html = Nokogiri::HTML File.open html_file
		begin
			year = html.xpath(".//input[@name='ano']").attr('value').value
			donator_id = html.xpath(".//input[@name='doador']").attr('value').value
			#import grantor using html locally
			import_asclaras_grantor(nil, html, donator_id, year)
			pp "grantor: "+donator_id+" year: "+year
		    pp '============================'
		rescue NoMethodError
			empty_donator << donator_id
		end
		#delete html file
		file_full_path = file_path + file_name
		pp 'deleting file: ' + file_full_path
		if !File.directory?(file_full_path)
		  File.delete(file_full_path)
		end
		pp 'deleted'
	  end
	}
  end

  def self.import_asclaras_grantor_by_range(range_begin, range_end, year)
    url_home = 'http://asclaras.org.br'
    url_grantor = "#{url_home}/@doador.php?doador=%{grantor_id}&ano=%{year}"
    m = Mechanize.new
    queue = Queue.new
    mutex = Mutex.new
	finished = false
	logged_donators = []
	#using mul-thread to handle assyncronous execution
    Thread.new do
      begin
        Thread.join_to_limit 3, [Thread.main]
		Thread.new do
		  error_count = 0
		  #range_end is imported (inclusive)
		  finished = true if range_begin >= range_end
		  pp '----------------------------'
		  begin
		    page = m.get(url_grantor % {:grantor_id => range_begin, :year => year})
		    queue << [page, range_begin, year]
            mutex.synchronize do
		  	  range_begin = range_begin + 1
		    end
		  rescue SystemCallError
			#create log file for further calls
            mutex.synchronize do
			  logged_donators << range_begin
			end
		  end
		end
	  end while !finished

      Thread.join_all [Thread.main]
	end
	#processing logged donator due to any erros for further processing.
	logged_donators.each do |logged_donator|
	  begin
		page = m.get(url_grantor % {:grantor_id => logged_donator, :year => year})
	    queue << [page, nil, logged_donator, year]
	  rescue SystemCallError
	    pp '----------------------------'
		pp 'error to import: ' + logged_donator.to_s
	  end
	end
    # queue processing
    while !finished
      if queue.empty?
        sleep 1
        next
      end
      item = queue.pop
	  import_asclaras_grantor(item[0], nil, item[1], item[2])
	  pp "grantor: %{grantor_id} year: %{year}" % {:grantor_id => item[1], :year => item[2]}
      pp '============================'
    end
  end

  def self.import_asclaras_grantor(page = nil, html = nil, grantor_id = nil, year = nil)
	#parsing page to html, a nokogiri node
	if !page.nil?
	  html = page.parser
	end
    span = html.css('span.destaque')[0]
	if !span.nil? && !span.children[0].nil?
		grantor_name = span.children[0].text
		#TODO:refactore - find a way to group cgc
		grantor_cgc = []
		html.css('tr#aba102 td.conteudo table tr').each do |tr|
		  data = tr.search('td')
		  next if data.count != 2
		  name, cgc = data[0].text, data[1].text
		  owner = Owner.first_or_new 'àsclaras', :cgc => cgc, :name => name
		  owner.save!
		  grantor = Grantor.first_or_new :asclaras_id => grantor_id, :owner_id => owner.id, :year => year
		  grantor.save!
		end
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
      legal_nature = row.values_at(3).first.squish

      company = Owner.first_or_new 'Receita', :cgc => cnpj, :name => name, :formal_name => formal_name
      company.formal_name = formal_name unless formal_name.blank?
      company.add_cgc cnpj unless cnpj.blank?
      company.legal_nature = legal_nature
      company.save!
      pp company
    end
  end

  def self.import_stockholders_csv(file)

    def self.get_shares_pair(string)
      string.to_s.split("\n").map do |share|
        if share =~ /(.+)\((.+)%?\)/
          name = $1.squish
          percentage = $2.squish.gsub(',', '.').to_f
        else
          name = share.squish
        end

        [name, percentage]
      end
    end

    csv = CSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first.squish
      cnpj = row.values_at(1).first
      source = row.values_at(2).first
      source_detail = row.values_at(3).first
      owners_shares = row.values_at(4).first
      owned_shares = row.values_at(5).first
      reference_date = $share_reference_date

      company = Owner.first_or_new source, :cgc => cnpj, :formal_name => name, :source_detail => source_detail
      company.save!

      get_shares_pair(owners_shares).each do |name, percentage|
        owner = Owner.first_or_new "#{source} associado", :formal_name => name
        owner.save!
        share = Share.first_or_new(:owner_id => owner.id, :company_id => company.id,
                                   :reference_date => reference_date, :sclass => 'ON',
                                   :name => name, :source => source)
        share.percentage = percentage
        share.save
      end
      get_shares_pair(owned_shares).each do |name, percentage|
        owned = Owner.first_or_new "#{source} associado", :formal_name => name
        owned.save!
        share = Share.first_or_new(:owner_id => company.id, :company_id => owned.id,
                                   :reference_date => reference_date, :sclass => 'ON',
                                   :name => name, :source => source)
        share.percentage = percentage
        share.save
      end
    end
  end

  def self.import_econoinfo options = {}

    def self.get_page(mech, stock_code)
      shareholders_url = "http://www.econoinfo.com.br/governanca/estrutura-acionaria?ce=%{stock_code}"
      balance_url = "http://www.econoinfo.com.br/sumario/a-empresa?ce=%{stock_code}"
      info_url = "http://www.econoinfo.com.br/demonstracoes-financeiras/demonstracao-do-resultado?ce=%{stock_code}"
      members_url = "http://www.econoinfo.com.br/governanca/alta-administracao?ce=%{stock_code}"
      mech.get shareholders_url % {:stock_code => stock_code}
      mech.get balance_url % {:stock_code => stock_code}
      mech.get info_url % {:stock_code => stock_code}
      mech.get members_url % {:stock_code => stock_code}
    rescue
    end

    def process_page(page)
    end

    Cache.enable
    m = Mechanize.new

    if stock_code = options[:stock_code]
      get_page m, stock_code
      return
    end

    Owner.all(:stock_code_base.ne => nil).each do |owner|
      get_page m, owner.stock_code_base
    end

  end

end
