module ImportHelper
	
  require 'mechanize'  

  def self.clear_db
    Owner.destroy_all
    Share.destroy_all
    Balance.destroy_all
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

        if field == 'balance_months'
          balance.save if balance
          balance = company.balances.build(:reference_date => reference_date)
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

  def self.import_asclaras()
	url_home = 'http://www.asclaras.org.br/'
	url_update_session = url_home + 'atualiza_sessao.php?ano='
	url_candidacy = url_home + 'partes/index/candidatos_frame.php?CAoffset='
	url_donation = url_home + 'candidato.php?CACodigo='

	m = Mechanize.new
	#array of years to import data
    years = [2008,2010]
	#cont to manage candidates pages
	i = 0 

	years.each do |year|
		#Output current year of data import 
		pp year

		#set session attributte 'year' 
		page = m.get(url_update_session + year.to_s)

		#TODO:add check how to get next page with others 20 candidacie and iterate each page
		page2 = m.get(url_candidacy + i.to_s)

		#TODO:remove candidate_id = "221720"
		candidate_id = "221720"
		
		#Get all link on a page as a Mechanize.Page.Link object
		page2.links().each do |link|		
			#Data used to manage a candidate at asclaras.org	
			if candidate_id.nil?
				candidate_id = link.href[-7..-3]				
			end			
			candidate_name = link.text()
			import_asclaras_donation(m,year,url_donation,candidate_id,candidate_name)
		end	
	end
  end
	
  def self.import_asclaras_donation(m,year,url_donation,candidate_id,candidate_name)

	page3 = m.get(url_donation + candidate_id.to_s)

	#In case there is owner referenced by owner_name get it's object, case not create a new one
	owner = Owner.find_or_create(nil, candidate_name.strip, nil)

	#In case there is candidacy referenced by owner get it's object
	candidacy = Candidacy.first(:year => year, :owner_id => owner.id)

	#In case not create a new one based on candidate_Data parsed  by Mechanize
	if candidacy.nil?
		candidacy = Candidacy.new(:year => year, :owner_id => owner.id) 
		candidate_data = page3.parser.css("table tr:nth-child(3) table th")
		candidacy.role = candidate_data[0].text().strip
		candidacy.party = candidate_data[1].text().strip	
		#index to control data index to import
		data_index = 0
		if "Vereador" == candidate_data[0].text().strip
			uf = candidate_data[2].text().strip
			candidacy.city = uf.split("-")[0].strip
			candidacy.state = uf.split("-")[1].strip
			data_index = 6
		else "Presidente" == candidate_data[0].text().strip
			candidacy.state = "BR"
			data_index = 5
		end
		if "Eleito" == candidate_data[data_index].text().strip
			candidacy.status = "elected"
		elsif "Não Eleito" == candidate_data[5].text().strip
			candidacy.status = "not elected"
		elsif "Suplente" == candidate_data[5].text().strip
			candidacy.status = "substitute"
		end				
	end
							
	left, center, right = false
	url_grantor, name_grantor, cgc_grantor, vl_donated = ""
	#return a nodeset from Nokogiri
	page3.parser.xpath("//table//tr[@id='doadores3']//td[@class='conteudo']//table//tr//td[@class='linhas']").each do |element|

		if (element.attr('align') == 'left')
			url_grantor = element.children().attr('href').value
			name_grantor = element.content.strip
			left = true
		end

		if (element.attr('align') == 'center')
			cgc_grantor = element.content.strip
			center = true
		end

		if (element.attr('align') == 'right')
			vl_donated = element.content.strip
			right = true
		end
						
		if (left && center && right)
			#In case there is owner referenced by owner_name get it's object, case not create a new one
			owner_grantor = Owner.find_or_create(cgc_grantor.gsub(/[,.\-\/]/, ''), name_grantor, nil)						
			owner_grantor.save!()									

			#In case there is candidacy referenced by owner get it's object, case not create a new one
			donation = Donation.first(:candidacy_id => candidacy.owner_id, 
									  :owner_id => owner_grantor.id)

			donation = Donation.new(:candidacy_id => candidacy.owner_id, 
									:owner_id => owner_grantor.id) if donation.nil?				

			if !vl_donated.nil? 
				if !vl_donated.split("R$")[1].nil?
					vl_donated = vl_donated.split("R$")[1]
					vl_donated = vl_donated.gsub(".","").gsub(",",".")
		
					pp name_grantor + ' ' + vl_donated
					#pp donation
					#donation.save!()

					#TODO: add try catch to log in case vl_donated couldn't be performed and why
					#use vl_donated_aux to future verification
				end 						
			end							

			#restart controller variables
			left, center, right = false
			url_grantor, name_grantor, cgc_grantor, vl_donated = ""
		end
	end
  end
end
