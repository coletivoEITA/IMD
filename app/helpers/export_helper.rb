# coding: UTF-8

module ExportHelper

  def self.export_companies_donations_by_party(options = {})
    FasterCSV.open("db/companeis-donation-by-party.csv", "w") do |csv|
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
    FasterCSV.open("db/grantor-donation-by-candidacy.csv", "w") do |csv|
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

  def self.export_owners_rankings(attr = :revenue, balance_reference_date = '2011-12-31', share_reference_date = '2012-09-05')

    def self.export_raking(attr = :revenue, balance_reference_date = '2011-12-31', share_reference_date = '2012-09-05')

      puts 'calculating values'
      CalculationHelper.calculate_owners_value attr, balance_reference_date, share_reference_date

      puts 'loading data'
      owners = Owner.order("total_#{attr}".to_sym.desc).all

      puts 'exporting data'
      CSV.open("db/#{attr}-ranking.csv", "w") do |csv|
        csv << ['i', 'contr?', 'nome', 'razão social', 'cnpj',
                'Receita líquida pela Valor (milhões de reias)', 'Receita líquida pela Economatica (milhões de reias)',
                '“Poder” indireto (das empresas em que i tem participação)', '“Poder” total (receita da empresa i + valor indireto)',
                'Indicador', 'Fonte',
                'Poder direto - controle', 'Poder direto - parcial',
                'Poder indireto - controle', 'Poder indireto - parcial',
                'Composição acionária direta', 'Estatal ou Privada?']

        total = owners.sum(&"total_#{attr}".to_sym)

        i = 1
        owners.each do |owner|
          owners_shares = owner.owners_shares.on.greatest.with_reference_date(share_reference_date).all
          owned_shares = owner.owned_shares.on.greatest.with_reference_date(share_reference_date).all

          controlled = owners_shares.first
          is_controlled = controlled && controlled.control?
          controlled = is_controlled ? 'sim' : ''

          # uncomment to skip controlled
          #next if is_controlled

          valor_value = owner.balances.valor.with_reference_date(balance_reference_date).first
          valor_value = valor_value.nil? ? '0.00' : (valor_value.value(attr)/1000000).c
          valor_value = '-' if valor_value == '0.00'
          economatica_value = owner.balances.economatica.with_reference_date(balance_reference_date).first
          economatica_value = economatica_value.nil? ? '0.00' : (economatica_value.value(attr)/1000000).c
          economatica_value = '-' if economatica_value == '0.00'

          indirect_value = (owner.send("indirect_#{attr}")/1000000).c
          indirect_value = '-' if indirect_value == '0.00'
          total_value = (owner.send("total_#{attr}")/1000000).c
          total_value = '-' if total_value == '0.00'
          index_value = total_value == '-' ? '-' : ((total_value.to_f / total)).c

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

          csv << [i.to_s, controlled, owner.name, owner.formal_name, "'#{owner.cgc.first}'",
                  valor_value, economatica_value,
                  indirect_value, total_value,
                  index_value, owner.source,
                  power_direct_control, power_direct_parcial,
                  power_indirect_control, power_indirect_parcial,
                  shareholders, owner.capital_type]
          i += 1 unless is_controlled
        end
      end
    end

    export_raking attr, '2011-12-31', '2012-09-05'
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
