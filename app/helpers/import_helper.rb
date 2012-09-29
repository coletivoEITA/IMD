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
    'Setor|Economática', nil,
    'Tipo de Ativo', nil,
    'Bolsa', :stock_market,
    'Código', :stock_code,
    'ISIN', nil,
    /Meses|.+|no exercício|consolid:sim*/, :balance_months,
    /Ativo Tot|.+|em moeda orig|em milhares|consolid:sim*/, :balance_total_active,
    /Patrim Liq|.+|em moeda orig|em milhares|consolid:sim*/, :balance_patrimony,
    /Receita|.+|em moeda orig|em milhares|no exercício|consolid:sim*/, :balance_revenue,
    /Lucro Bruto|.+|em moeda orig|em milhares|no exercício|consolid:sim*/, :balance_gross_profit,
    /Lucro Liq|.+|em moeda orig|em milhares|no exercício|consolid:sim*/, :balance_net_profit,
    /Moeda dos|Balanços/, :balance_currency,
    /Qtd Ações|Outstanding|da empresa|em milhares|.+/, :shares_quantity,
    /LPA|.+|em moeda orig|de 12 meses|consolid:sim*|ajust p\/ prov/, nil,
    /VPA|.+|em moeda orig|consolid:sim*|ajust p\/ prov/, nil,
    /Vendas\/Acao|.+|em moeda orig|de 12 meses|consolid:sim*|ajust p\/ prov/, nil,
    /Divid por Ação|.+|1 anos|em moeda orig/, nil,
    /Div Yld (fim)|.+|no Ano|em moeda orig/, nil,
    /Div Yld (inic)|.+|1 anos|em moeda orig/,nil,
    /PrinAcion|.+|1.Maior|Sem Voto/, :shareholder_PN_01_name,
    /%AcPoss|.+|1.Maior|Sem Voto/, :shareholder_PN_01_percentage,
    /PrinAcion|.+|2.Maior|Sem Voto/, :shareholder_PN_02_name,
    /%AcPoss|.+|2.Maior|Sem Voto/, :shareholder_PN_02_percentage,
    /PrinAcion|.+|3.Maior|Sem Voto/, :shareholder_PN_03_name,
    /%AcPoss|.+|3.Maior|Sem Voto/, :shareholder_PN_03_percentage,
    /PrinAcion|.+|4.Maior|Sem Voto/, :shareholder_PN_04_name,
    /%AcPoss|.+|4.Maior|Sem Voto/, :shareholder_PN_04_percentage,
    /PrinAcion|.+|5.Maior|Sem Voto/, :shareholder_PN_05_name,
    /%AcPoss|.+|5.Maior|Sem Voto/, :shareholder_PN_05_percentage,
    /PrinAcion|.+|6.Maior|Sem Voto/, :shareholder_PN_06_name,
    /%AcPoss|.+|6.Maior|Sem Voto/, :shareholder_PN_06_percentage,
    /PrinAcion|.+|7.Maior|Sem Voto/, :shareholder_PN_07_name,
    /%AcPoss|.+|7.Maior|Sem Voto/, :shareholder_PN_07_percentage,
    /PrinAcion|.+|8.Maior|Sem Voto/, :shareholder_PN_08_name,
    /%AcPoss|.+|8.Maior|Sem Voto/, :shareholder_PN_08_percentage,
    /PrinAcion|.+|9.Maior|Sem Voto/, :shareholder_PN_09_name,
    /%AcPoss|.+|9.Maior|Sem Voto/, :shareholder_PN_09_percentage,
    /PrinAcion|.+|10.Maior|Sem Voto/, :shareholder_PN_10_name,
    /%AcPoss|.+|10.Maior|Sem Voto/, :shareholder_PN_10_percentage,
    /PrinAcion|.+|1.Maior|Com Voto/, :shareholder_ON_01_name,
    /%AcPoss|.+|1.Maior|Com Voto/, :shareholder_ON_01_percentage,
    /PrinAcion|.+|2.Maior|Com Voto/, :shareholder_ON_02_name,
    /%AcPoss|.+|2.Maior|Com Voto/, :shareholder_ON_02_percentage,
    /PrinAcion|.+|3.Maior|Com Voto/, :shareholder_ON_03_name,
    /%AcPoss|.+|3.Maior|Com Voto/, :shareholder_ON_03_percentage,
    /PrinAcion|.+|4.Maior|Com Voto/, :shareholder_ON_04_name,
    /%AcPoss|.+|4.Maior|Com Voto/, :shareholder_ON_04_percentage,
    /PrinAcion|.+|5.Maior|Com Voto/, :shareholder_ON_05_name,
    /%AcPoss|.+|5.Maior|Com Voto/, :shareholder_ON_05_percentage,
    /PrinAcion|.+|6.Maior|Com Voto/, :shareholder_ON_06_name,
    /%AcPoss|.+|6.Maior|Com Voto/, :shareholder_ON_06_percentage,
    /PrinAcion|.+|7.Maior|Com Voto/, :shareholder_ON_07_name,
    /%AcPoss|.+|7.Maior|Com Voto/, :shareholder_ON_07_percentage,
    /PrinAcion|.+|8.Maior|Com Voto/, :shareholder_ON_08_name,
    /%AcPoss|.+|8.Maior|Com Voto/, :shareholder_ON_08_percentage,
    /PrinAcion|.+|9.Maior|Com Voto/, :shareholder_ON_09_name,
    /%AcPoss|.+|9.Maior|Com Voto/, :shareholder_ON_09_percentage,
    /PrinAcion|.+|10.Maior|Com Voto/, :shareholder_ON_10_name,
    /%AcPoss|.+|10.Maior|Com Voto/, :shareholder_ON_10_percentage,
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
    csv = FasterCSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first
      cnpj = row.values_at(2).first
      country = row.values_at(3).first

      next if country != 'BR' # only brazilian companies
      next if cnpj == '-'

      cnpj = cnpj.to_i
      cnpj = cnpj.zero? ? nil : ('%014d' % cnpj) # fix CNPJ format

      company = Owner.find_or_create cnpj, name
      balance = nil
      shareholder = nil

      column_index = 0
      row.each do |header, value|
        field = column_index_to_field(column_index).to_s
        column_index += 1
        next if field.blank?

        # jump preprocessed
        next if ['cgc', 'name'].include?(field)

        if field == 'balance_months'
          balance.save if balance
          balance = company.balances.build(:source => 'Economatica', :reference_date => reference_date)
        end
        if field =~ /shareholder_(.+)_(.+)_name/
          shareholder.save if shareholder
          shareholder = company.owners_shares.build(:reference_date => reference_date, :type => $1)
        end

        next if value.blank? or value == '-' or value == '0.0'

        if field.starts_with?('balance')
          balance.send "#{$1}=", value if field =~ /balance_(.+)/
        elsif field.starts_with?('shareholder')
          shareholder.send "#{$3}=", value if field =~ /shareholder_(.+)_(.+)_(.+)/
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
      balance.save if balance
      shareholder.save if shareholder
      company.save!
    end
  end

  def self.import_receita_companies_members
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
      formal_name = page.parser.css("td[valign=center] font[size='3']")[1].text.strip
      company = Owner.find_or_create cnpj, nil, formal_name
      mapping = {
        'CPF/CNPJ:' => :cgc,
        'Nome/Nome Empresarial:' => :formal_name,
        'Entrada na Sociedade:' => :entrance_date,
        'Qualificação:' => :qualification,
        'Part. Capital Social:' => :participation,
      }

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

        owner_member = Owner.find_or_create cgc, nil, formal_name
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

    # mark as cheched to FII companies which
    # tipycally has no members
    #Owner.each{ |o| next unless o.name_d.starts_with?('fii '); o.members_count = 0; o .save }

    Owner.each do |owner|
      next if owner.cgc.first.nil?
      next if !owner.cnpj?
      next if owner.members_count

      cnpj = owner.cgc.first
      page = nil

      # HTTP 500 error
      next if ['97837181000147', '08467115000100'].include?(cnpj)

      puts '==============================='
      pp owner

      loop do
        break if page = get_page(cnpj)
        puts 'Error while getting page, try again'
      end
      parse_page(cnpj, page)
    end

  end


  def self.import_companies(*files)
    csvs = *files.map do |file|
      FasterCSV.table file, :converters => nil
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

      company = nil
      formal_name_d = formal_name.downcase

      cgc_list.each do |cgc|
        company = Owner.find_by_cgc(cgc)
        break if company
      end
      company ||= Owner.find_by_formal_name_d formal_name_d
      company ||= Owner.find_by_name_d formal_name_d
      company ||= Owner.new :formal_name => formal_name

      company.formal_name = formal_name
      cgc_list.each do |cgc|
        company.add_cgc cgc
      end

      pp company
      company.save!
    end
  end

  def self.import_exame_maiores
    url = "http://exame.abril.com.br/negocios/melhores-e-maiores/empresas/maiores/%{page}/%{year}/%{attr}"
    pages = 125
    years = [2011]
    attributes = {
      'vendas' => :revenue,
      'total-do-ativo' => :total_active,
    }

    m = Mechanize.new

    years.each do |year|
      reference_date = Time.mktime(2011).end_of_year.to_date.strftime('%Y-%m-%d')

      attributes.each do |attr, key|
        (1..pages).each do |page|
          page = m.get(url % {:year => year, :attr => attr, :page => page})

          trs = page.parser.css 'table.table_mm_g tr[class*=row]'
          trs.each do |tr|
            tds = tr.children.select{ |td| td.element? }
            name = tds[3].text
            formal_name = tds[2].text

            owner = Owner.find_or_create nil, name, formal_name
            owner.sector = tds[4].text
            owner.capital_type = tds[5].text == 'Privada' ? 'private' : 'state'
            owner.save!
            pp owner

            balance = Balance.first_or_new(:company_id => owner.id, :source => 'Exame', :reference_date => reference_date)
            value = tds[7].text.gsub('.', '').gsub(',', '.').to_f * 1000
            balance.send "#{key}=", value
            balance.save!
            pp balance
          end
        end
      end
    end
  end

  def self.import_asclaras(options = {})
    url_home = 'http://asclaras.org.br'
    url_update_session = "#{url_home}/atualiza_sessao.php?ano=%{year}"
    url_candidacy = "#{url_home}/partes/index/candidatos_frame.php?CAoffset=%{offset}"
    url_donation = "#{url_home}/candidato.php?CACodigo=%{candidate_id}"

    m = Mechanize.new
    years = options[:year] ? [options[:year]] : [2002, 2004, 2006, 2008, 2010]

    if candidate_id = options[:candidate_id]
      year = years.first
      m.get(url_update_session % {:year => year})
      page = m.get(url_donation % {:candidate_id => candidate_id})
      import_asclaras_donation(page, year)
      return
    end

    years.each do |year|
      #set session attributte 'year'
      m.get(url_update_session % {:year => year})

      offset = options[:offset] || 0
      begin
        page = m.get(url_candidacy % {:offset => offset})
        links = page.links

        pp '----------------------------'
        pp "offset: #{offset}"

        #Get all link on a page as a Mechanize.Page.Link object
        links.each do |link|
          next unless link.href =~ /CACodigo=(.+)'/
          candidate_id = $1
          pp '============================'
          pp candidate_id

          page = m.get(url_donation % {:candidate_id => candidate_id})
          import_asclaras_donation(page, year)
        end

        offset += links.count
      end while links.count > 0
    end
  end

  def self.import_asclaras_donation(page, year)
    candidate_name = page.parser.css('td.tituloI')[0].text

    #In case there is owner referenced by owner_name get it's object, case not create a new one
    candidate = Owner.find_or_create(nil, candidate_name, nil)
    pp candidate
    candidate.save!

    #In case there is candidacy referenced by candidate get it's object
    candidacy = Candidacy.first_or_new(:year => year, :candidate_id => candidate.id)
    #In case not create a new one based on candidate_Data parsed  by Mechanize
    if candidacy.new_record?
      candidate_data = page.parser.css("table tr:nth-child(3) table th")
      candidacy.role = candidate_data[0].text.strip
      candidacy.party = candidate_data[1].text.strip

      #index to control data index to import
      data_index = 0
      if "Vereador" == candidate_data[0].text.strip
        uf = candidate_data[2].text().strip
        candidacy.city = uf.split("-")[0].strip
        candidacy.state = uf.split("-")[1].strip
        data_index = 6
      else "Presidente" == candidate_data[0].text.strip
        candidacy.state = "BR"
        data_index = 5
      end

      if "Eleito" == candidate_data[data_index].text.strip
        candidacy.status = "elected"
      elsif "Não Eleito" == candidate_data[5].text.strip
        candidacy.status = "not_elected"
      elsif "Suplente" == candidate_data[5].text.strip
        candidacy.status = "substitute"
      end
    end
    candidacy.save!

    page.parser.css("table #doadores3 td.conteudo table tr").each do |tr|
      data = tr.css('td.linhas') + tr.css('td.linhas2')
      next if data.count != 3

      name = data[0].content.strip
      cgc = data[1].content.strip
      value = data[2].content.strip

      name = '<not specified>' if name.blank?

      cgc = nil if cgc == 'CGC Inválido'
      # fix invalid CGC
      cgc = '223.241.190-72' if cgc == '223.241.19 -72'

      if value =~ /R\$.(.+)/
        value = $1.gsub(".","").gsub(",",".").to_f
      else
        next
      end

      grantor = Owner.find_or_create(cgc, name, nil)
      grantor.save!

      donation = Donation.first_or_new(:candidacy_id => candidacy.id, :grantor_id => grantor.id, :value => value)
      donation.save!
    end
  end
end
