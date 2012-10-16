# coding: UTF-8

module ExportHelper

  def self.export_companies_donations_by_party(options = {})
    CSV.open("output/companeis-donation-by-party.csv", "w") do |csv|
	  #set header
      csv << ['nome', 'razão social', 'cnpj', 'total doado', '% por partido']
	  #TODO:refactore - filter donation by option arguments
      Owner.all.each do |owner|
		#check if the owner is a company or a person
		next if owner.cgc.length < 14

		#TODO:refactore - performance check if filter before count reduce processing time
	    #check if company has donated something
		next if owner.donations_made.count == 0
		#filter by options parametes passed by
		donations = owner.donations_made.all(:year => year, :state => state, :city => city)

		sum_donated = owner.donations_made.sum(&:value)
		#concat a percentage by party
		percentage_by_party = owner.donations_made.group_by{ |d| d.candidacy.party }.map do |party, donations|
		  percentage = (donations.sum(&:value) / sum_donated) * 100
		  #TODO:refactore - round percentage to 35.0 => 35... 34.90999 => 34.91
		  "#{party} (#{percentage}%)"
		end.join(' ')
		#create on line of grantor donations by party
		csv << [owner.name, owner.formal_name, owner.cgc.first,
			  sum_donated, percentage_by_party]
	  end
    end
  end

  def self.export_grantor_donations_by_candidacy
    CSV.open("output/grantor-donation-by-candidacy.csv", "w") do |csv|
	  #set header
      csv << ['nome', 'razão social', 'cnpj',
              'total doado', '% por candidatura']
	  #TODO:refactore - filter donation by option arguments
  	  Owner.all.each do |owner|
	  	next if owner.donations_received.count == 0
	    sum_donated = owner.donations_made.sum(&:value)
		#concat a percentage by candidacy
  	    percentage_by_candidacy = owner.donations_made.group_by{ |d| d.candidacy }.map do |candidacy, donations|
	      percentage = (donations.sum(&:value) / sum_donated) * 100
	      "#{candidacy.year} - #{candidacy.candidate.name} - #{candidacy.role} (#{percentage})"
		end.join(' ')
   		#create on line of grantor donations by party
        csv << [owner.name, owner.formal_name, owner.cgc.first,
                sum_donated, percentage_by_candidacy]
      end
    end
  end

  def self.export_owners_rankings(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)

    def self.export_raking(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)

      puts 'calculating values'
      #Share.each{ |s| s.calculate_percentage; s.save }
      #CalculationHelper.calculate_owners_value attr, balance_reference_date, share_reference_date

      puts 'loading data'
      value_field = "total_#{attr}".to_sym
      owners = Owner.order(value_field.desc).where(:name.ne => 'Acoes em Tesouraria').all
      #total = owners.sum(&value_field)

      puts 'exporting data'
      CSV.open("output/#{attr}-ranking.csv", "w") do |csv|
        csv << ['Posição no Ranking', 'Controlada?', 'Nome', 'Razão Social', 'CNPJ',
                'Natureza Jurídica', 'Código BOVESPA',
                'Receita líquida pela Valor (milhões de reias)', 'Receita líquida pela Economatica (milhões de reias)',
                '“Poder” indireto (das empresas em que i tem participação)', '“Poder” total (receita da empresa i + valor indireto)',
                'Indicador (por milhão de rendas médias)', 'Fonte',
                'Poder direto - controle', 'Poder direto - parcial',
                'Poder indireto - controle', 'Poder indireto - parcial',
                'Composição acionária direta', 'Estatal ou Privada?']

        i = 0
        owners.each do |owner|
          cgc = owner.cgc.first
          cgc = cgc ? CgcHelper.format(cgc) : '-'

          legal_nature = owner.legal_nature || '-'
          stock_code = owner.stock_code_base

          owners_shares = owner.owners_shares.on.greatest.with_reference_date(share_reference_date).all
          owned_shares = owner.owned_shares.on.greatest.with_reference_date(share_reference_date).all

          controller = owner.controller
          is_controlled = controller && controller.id != $uniao.id
          controlled = is_controlled ? 'sim' : ''

          # uncomment to skip controlled
          #next if is_controlled

          position = is_controlled ? '-' : i.to_s
          i += 1 unless is_controlled

          valor_value = owner.balances.valor.with_reference_date(balance_reference_date).first
          valor_value = valor_value.nil? ? '0.00' : (valor_value.value(attr)/1000000).c
          valor_value = '-' if valor_value == '0.00'
          economatica_value = owner.balances.economatica.with_reference_date(balance_reference_date).first
          economatica_value = economatica_value.nil? ? '0.00' : (economatica_value.value(attr)/1000000).c
          economatica_value = '-' if economatica_value == '0.00'

          balance = owner.balance_with_value(attr, balance_reference_date)
          source = balance.nil? ? owner.source : balance.source_with_months

          indirect_value = (owner.send("indirect_#{attr}")/1000000).c
          indirect_value = '-' if indirect_value == '0.00'
          total_value = (owner.send("total_#{attr}")/1000000).c
          total_value = '-' if total_value == '0.00'
          index_value = total_value == '-' ? '-' : (total_value.to_f / (1345 * 12)).c

          power_direct_control = owned_shares.select{ |s| s.control? }.map do |s|
            "#{s.company.name} (#{s.percentage.c}%)"
          end.join("\n")
          power_direct_parcial = owned_shares.select{ |s| s.parcial? }.map do |s|
            "#{s.company.name} (#{s.percentage.c}%)"
          end.join("\n")

          power_indirect_control = owner.indirect_total_controlled_companies(share_reference_date).join("\n")
          power_indirect_parcial = owner.indirect_parcial_controlled_companies(share_reference_date).join("\n")

          shareholders = owners_shares.select{ |s| s.percentage }.map do |s|
            "#{s.owner.name} (#{s.percentage.c}%)"
          end.join("\n")

          #shares_percent_sum = owners_shares.sum{ |s| s.percentage.nil? ? 0 : s.percentage }

          csv << [position, controlled, owner.name, owner.formal_name, cgc,
                  legal_nature, stock_code,
                  valor_value, economatica_value,
                  indirect_value, total_value,
                  index_value, source,
                  power_direct_control, power_direct_parcial,
                  power_indirect_control, power_indirect_parcial,
                  shareholders, owner.capital_type]
        end
      end
    end

    export_raking attr, $balance_reference_date, $share_reference_date
    true
  end

  def self.export_owners
    File.open('owners.txt', 'w') do |f|
      cc = Owner.all.map{ |c| "#{c.name} (Empresa)\t#{c.cnpj}" }.uniq
      ss = Share.all.map{ |c| c.name }.uniq
      f.write((cc+ss).sort.join("\n"))
    end
  end

end
