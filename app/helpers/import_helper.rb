module ImportHelper

  def self.clear_db
    Owner.destroy_all
    Share.destroy_all
    Balance.destroy_all
    Candidacy.destroy_all
    Donation.destroy_all
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
    'Meses|Dez 2011|no exercício|consolid:sim*', :balance_months,
    'Ativo Tot|Dez 2011|em moeda orig|em milhares|consolid:sim*', :balance_total_active,
    'Patrim Liq|Dez 2011|em moeda orig|em milhares|consolid:sim*', :balance_patrimony,
    'Receita|Dez 2011|em moeda orig|em milhares|no exercício|consolid:sim*', :balance_revenue,
    'Lucro Bruto|Dez 2011|em moeda orig|em milhares|no exercício|consolid:sim*', :balance_gross_profit,
    'Lucro Liq|Dez 2011|em moeda orig|em milhares|no exercício|consolid:sim*', :balance_net_profit,
    'Moeda dos|Balanços', :balance_currency,
    'Qtd Ações|Outstanding|da empresa|em milhares|31Dez11', :shares_quantity,
    'LPA|Dez 2011|em moeda orig|de 12 meses|consolid:sim*|ajust p/ prov', nil,
    'VPA|Dez 2011|em moeda orig|consolid:sim*|ajust p/ prov', nil,
    'Vendas/Acao|Dez 2011|em moeda orig|de 12 meses|consolid:sim*|ajust p/ prov', nil,
    'Divid por Ação|31Dez11|1 anos|em moeda orig', nil,
    'Div Yld (fim)|31Dez11|no Ano|em moeda orig', nil,
    'Div Yld (inic)|31Dez11|1 anos|em moeda orig',nil,
    'PrinAcion|31/12/2011|1.Maior|Sem Voto', :shareholder_PN_01_name,
    '%AcPoss|31/12/2011|1.Maior|Sem Voto', :shareholder_PN_01_percentage,
    'PrinAcion|31/12/2011|2.Maior|Sem Voto', :shareholder_PN_02_name,
    '%AcPoss|31/12/2011|2.Maior|Sem Voto', :shareholder_PN_02_percentage,
    'PrinAcion|31/12/2011|3.Maior|Sem Voto', :shareholder_PN_03_name,
    '%AcPoss|31/12/2011|3.Maior|Sem Voto', :shareholder_PN_03_percentage,
    'PrinAcion|31/12/2011|4.Maior|Sem Voto', :shareholder_PN_04_name,
    '%AcPoss|31/12/2011|4.Maior|Sem Voto', :shareholder_PN_04_percentage,
    'PrinAcion|31/12/2011|5.Maior|Sem Voto', :shareholder_PN_05_name,
    '%AcPoss|31/12/2011|5.Maior|Sem Voto', :shareholder_PN_05_percentage,
    'PrinAcion|31/12/2011|6.Maior|Sem Voto', :shareholder_PN_06_name,
    '%AcPoss|31/12/2011|6.Maior|Sem Voto', :shareholder_PN_06_percentage,
    'PrinAcion|31/12/2011|7.Maior|Sem Voto', :shareholder_PN_07_name,
    '%AcPoss|31/12/2011|7.Maior|Sem Voto', :shareholder_PN_07_percentage,
    'PrinAcion|31/12/2011|8.Maior|Sem Voto', :shareholder_PN_08_name,
    '%AcPoss|31/12/2011|8.Maior|Sem Voto', :shareholder_PN_08_percentage,
    'PrinAcion|31/12/2011|9.Maior|Sem Voto', :shareholder_PN_09_name,
    '%AcPoss|31/12/2011|9.Maior|Sem Voto', :shareholder_PN_09_percentage,
    'PrinAcion|31/12/2011|10.Maior|Sem Voto', :shareholder_PN_10_name,
    '%AcPoss|31/12/2011|10.Maior|Sem Voto', :shareholder_PN_10_percentage,
    'PrinAcion|31/12/2011|1.Maior|Com Voto', :shareholder_ON_01_name,
    '%AcPoss|31/12/2011|1.Maior|Com Voto', :shareholder_ON_01_percentage,
    'PrinAcion|31/12/2011|2.Maior|Com Voto', :shareholder_ON_02_name,
    '%AcPoss|31/12/2011|2.Maior|Com Voto', :shareholder_ON_02_percentage,
    'PrinAcion|31/12/2011|3.Maior|Com Voto', :shareholder_ON_03_name,
    '%AcPoss|31/12/2011|3.Maior|Com Voto', :shareholder_ON_03_percentage,
    'PrinAcion|31/12/2011|4.Maior|Com Voto', :shareholder_ON_04_name,
    '%AcPoss|31/12/2011|4.Maior|Com Voto', :shareholder_ON_04_percentage,
    'PrinAcion|31/12/2011|5.Maior|Com Voto', :shareholder_ON_05_name,
    '%AcPoss|31/12/2011|5.Maior|Com Voto', :shareholder_ON_05_percentage,
    'PrinAcion|31/12/2011|6.Maior|Com Voto', :shareholder_ON_06_name,
    '%AcPoss|31/12/2011|6.Maior|Com Voto', :shareholder_ON_06_percentage,
    'PrinAcion|31/12/2011|7.Maior|Com Voto', :shareholder_ON_07_name,
    '%AcPoss|31/12/2011|7.Maior|Com Voto', :shareholder_ON_07_percentage,
    'PrinAcion|31/12/2011|8.Maior|Com Voto', :shareholder_ON_08_name,
    '%AcPoss|31/12/2011|8.Maior|Com Voto', :shareholder_ON_08_percentage,
    'PrinAcion|31/12/2011|9.Maior|Com Voto', :shareholder_ON_09_name,
    '%AcPoss|31/12/2011|9.Maior|Com Voto', :shareholder_ON_09_percentage,
    'PrinAcion|31/12/2011|10.Maior|Com Voto', :shareholder_ON_10_name,
    '%AcPoss|31/12/2011|10.Maior|Com Voto', :shareholder_ON_10_percentage,
  ]
  def self.header_to_field(header)
    EconomaticaCSVColumns[header]
  end
  def self.column_to_field(csv, column_index)
    header = csv.headers[column_index]
    header_to_field(header)
  end

  def self.import_economatica_csv(file, reference_date)
    csv = FasterCSV.table file, :headers => true, :header_converters => nil, :converters => nil
    csv.each_with_index do |row, i|
      name = row.values_at(0).first
      cnpj = row.values_at(2).first
      next if cnpj == '-'

      company = Owner.find_or_create cnpj, name
      balance = nil
      shareholder = nil

      row.each do |header, value|
        field = header_to_field(header).to_s
        next if field.blank?

        # only brazilian companies
        next if field == 'country' and value != 'BR'

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
    cnpj = '42150391000170'

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

        cgc = attributes[:cgc].gsub(/[,.\-\/]/, '')
        formal_name = attributes[:formal_name]
        member = CompanyMember.new
        member.member = Owner.find_or_create cgc, nil, formal_name
        member.entrance_date = attributes[:entrance_date]
        member.qualification = attributes[:qualification]
        member.participation = attributes[:participation]

        company.members << member
      end
    end

    page = nil
    loop do
      page = get_page(cnpj)
      break if page
      puts 'Error while getting page, try again'
    end
    parse_page(cnpj, page)

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

  def self.import_asclaras()
	url_home = 'http://www.asclaras.org.br/'
	url_update_session = url_home + 'atualiza_sessao.php?ano='
	url_candancy = url_home + 'partes/index/candidatos_frame.php?CAoffset='
	url_donation = url_home + 'candidato.php?CACodigo='

	m = Mechanize.new
	#array of years to import data
    years = [2008, 2010]
	#cont to manage candidates pages
	i = 0

	years.each do |year|
		#Output current year of data import
		pp year

		#set session attributte 'year'
		page = m.get(url_update_session + year.to_s)

		#TODO:add check how to get next page with others 20 candidacie and iterate each page
		page2 = m.get(url_candancy + i.to_s)

		#Get all link on a page as a Mechanize.Page.Link object
		page2.links().each do |link|
			#Data used to manage a candidate at asclaras.org
			candidate_id = link.href[-7..-3]
			candidate_name = link.text()

			#TODO:refactor - how to check is a object exist and if yes set to a variable, if not run a block-code
			#In case owner_name exist get it's object, case not create a new owner
			#owner = nil
			#if Owner.find_by_name(candidate_name.strip)?
			#	owner = Owner.find_by_name(candidate_name.strip)
			#else
			#	owner = Owner.new
			#	owner.name = candidate_name
			#	if owner.valid?
			#		owner.save()
			#	end
			#end

			#TODO:remove - print the owner related to candidate
			#pp owner

			#TODO:refactor - how to check is a object exist and if yes set to a variable, if not run a block-code
			#candidacy = nil
			#if Candidacy.find_by_owner_id(owner.id)?
			#	candidacy = Candidacy.find_by_owner_id(owner.id)
			#else
			#	candidacy = Candidacy.new
			#	candidacy.owner_id = owner.id
			#	candidacy.year = year
			#end

			candidacy = Candidacy.new
			candidacy.year = year

			page3 = m.get(url_donation + candidate_id.to_s)
			page3.parser.xpath("//table[@class='tabelaPrincipal']//tr//td[@colspan='2']//table//tr//th[@align='left']").each do |candidate_td|
				th = 0
				puts candidate_td.text()
				case th
					when 2, 3, 4
						#do nothing
						th = th + 1
					when 0
						candidacy.roll = candidate_td.text()
						th = th + 1
					when 1
						candidacy.party = candidate_td.text()
						th = th + 1
					when 5
						candidacy.status = candidate_td.text()
						if candidacy.valid?
							puts candidacy.to_s
						else
							puts 'Candidacy not valid!'
						end
						th = th + 1
				end

				left, center, right = false
				url_grantor, name_grantor, cgc_grantor, vl_donated = ""

				File.open('data_from_asclaras/test_'+year.to_s+'_'+candidate_id.to_s+'_grantors.csv', 'w') do |f2|
					#TODO: remove - add header CSV to file
					f2.puts 'url_grantor;name_grantor;cgc_grantor;vl_donated;'

					#return a noteset of Nokogiri nodes element
	 				page3.parser.xpath("//table[@class='tabelaPrincipal']//tr[@id='doadores3']//td[@class='linhas']",
									   "//table[@class='tabelaPrincipal']//tr[@id='doadores3']//td[@class='linhas2']").each do |element|

						if (element.attr('align') == 'left')
							url_grantor = element.children().attr('href').value
							name_grantor = element.content
							left = true
						end

						if (element.attr('align') == 'center')
							cgc_grantor = element.content
							center = true
						end

						if (element.attr('align') == 'right')
							vl_donated = element.content
							right = true
						end

						if (left && center && right)

							f2.puts url_grantor.to_s.strip+
								';'+name_grantor.to_s.strip+
								';'+cgc_grantor.to_s.strip+
								';'+vl_donated.to_s.strip+";"
							#repalce file 'f2' for database persistence

							#restart controller variables
							left, center, right = false
							url_grantor, name_grantor, cgc_grantor, vl_donated = ""
						end
					end
				end
			end
		end
	end
  end

end
