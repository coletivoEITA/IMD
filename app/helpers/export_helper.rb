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
		csv << [owner.name.first, owner.formal_name.first, owner.cgc.first,
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
	      "#{candidacy.year} - #{candidacy.candidate.name.first} - #{candidacy.role} (#{percentage})"
		end.join(' ')
   		#create on line of grantor donations by party
        csv << [owner.name.first, owner.formal_name.first, owner.cgc.first,
                sum_donated, percentage_by_candidacy]
      end
    end
  end

  def self.export_econoinfo_company
    CSV.open("output/econoinfo-company-codes.csv", "w") do |csv|
      csv << ['nome da empresa', 'ce']
      Owner.all(:econoinfo_ce.ne => nil).each do |company|
        csv << [company.name.first, company.econoinfo_ce]
      end
    end
  end

  def self.export_econoinfo_shareholders(data)
    CSV.open("output/econoinfo-assoc.csv", "w") do |csv|
      csv << ['empresa', 'associado']

      data.each do |parent, assoc|
        next if parent.blank?
        csv << [parent, assoc]
      end
    end
  end

  def self.export_owners_rankings(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)

    def self.export_raking(attr, balance_reference_date, share_reference_date)

      puts 'calculating values'
      #CalculationHelper.calculate_owners_value attr, balance_reference_date, share_reference_date

      puts 'loading'
      value_field = "total_#{attr}".to_sym
      owners = Owner.order(value_field.desc).all
      #owners = Owner.all :name => /braskem/i

      puts 'loading participations'
      owners_participations = {}
      owners.each do |owner|
        participations = {}

        power_direct_control = owner.owned_shares(share_reference_date).select{ |s| s.control? }.map do |s|
          "#{s.company.name.first} (#{s.percentage.c}#{'%' if s.percentage})"
        end
        power_direct_parcial = owner.owned_shares(share_reference_date).select{ |s| s.parcial? }.map do |s|
          "#{s.company.name.first} (#{s.percentage.c}#{'%' if s.percentage})"
        end

        power_indirect_control = owner.indirect_total_controlled_companies(share_reference_date)
        power_indirect_parcial = owner.indirect_parcial_controlled_companies(share_reference_date)

        participations = {:direct_control => power_direct_control, :direct_parcial => power_direct_parcial,
                          :indirect_control => power_indirect_control, :indirect_parcial => power_indirect_parcial}
        participations[:count] = participations.values.inject(0){ |s, p| s+p.count }

        owners_participations[owner] = participations
      end

      puts 'sorting'
      owners = owners.sort do |a, b|
        comp = a.send("total_#{attr}") <=> b.send("total_#{attr}")
        next -comp unless comp.nil? or comp.zero?
        comp = owners_participations[a][:count] <=> owners_participations[b][:count]
        next -comp unless comp.nil? or comp.zero?
        comp = a.name.first <=> b.name.first
      end

      puts 'exporting'
      CSV.open("output/#{attr}-ranking.csv", "w") do |csv|
        csv << ['R', 'Contr.', 'Obs', 'Tipo de capital',
                'PA (milhões de reais)', 'Empresa ou Pessoa',
                'Controlada diretamente por:', 'Controlada indiretamente por:',
                #'Atividades controladas',
                'Controle direto', 'Participação direta', 'Controle indireto', 'Participação indireta (sem controle)',
                'CNPJ', 'Cód. Bovespa', 'Fonte', 'Receita líquida (milhões de reias)',
                '“Poder” Indireto (milhões de reais)', 'PA (milhões de reais)',]

        i = 0
        owners.each do |owner|
          pp owner

          is_controller = owner.controller?(share_reference_date) ? 'é controladora' : ''

          cgc = owner.cgc.first
          cgc = cgc ? CgcHelper.format(cgc) : '-'

          #legal_nature = owner.legal_nature || '-'
          stock_code = owner.stock_code_base

          value = (owner.value(attr, balance_reference_date)/1000000).c

          balance = owner.balance_with_value(attr, balance_reference_date)
          source = balance.nil? ? owner.source : balance.source_with_months

          own_value = (owner.send("own_#{attr}")/1000000).c
          indirect_value = (owner.send("indirect_#{attr}")/1000000).c
          total_value = (owner.send("total_#{attr}")/1000000).c
          #index_value = total_value == '-' ? '-' : (total_value.to_f / (1345 * 12)).c(4)

          shareholders = owner.owners_shares(share_reference_date).map do |s|
            "#{s.owner.name.first} (#{s.percentage.c}#{'%' if s.percentage})"
          end.join("\n")

          participations = owners_participations[owner]
          participations.each{ |k, v| next if k == :count; participations[k] = v.join "\n" }

          has_participation = participations[:count] > 0
          has_own_value = own_value != '-'

          ps = ''
          if owner.company? and (!has_participation or !has_own_value)
            ps << 'nc ' if !has_participation
            ps << 'nv' if !has_own_value
          end

          #ou controla, ou participa de alguem que controla
          if owner.person?
            position = 'pessoa'
          elsif owner.controlled?(share_reference_date) and owner.controller(share_reference_date).company?
            position = 'controlada'
          elsif owner.eper?(attr, share_reference_date)
            position = 'eper'
          else
            position = i.to_s
          end
          i += 1 if position.number?

          indirect_controllers = ''
          #indirect_controllers = owner.indirect_controllers share_reference_date
          #activity_control_tree = owner.activity_control_tree(share_reference_date).join "\n"

          capital_type = '' unless ['Governo', 'Estatal'].include? owner.capital_type

          csv << [position, is_controller, ps, capital_type,
                  total_value, owner.name.first,
                  shareholders, indirect_controllers,
                  #activity_control_tree,
                  participations[:direct_control], participations[:direct_parcial],
                  participations[:indirect_control], participations[:indirect_parcial],
                  cgc, stock_code, source, value,
                  indirect_value, total_value,]
        end
      end
    end

    export_raking attr, balance_reference_date, share_reference_date
    true
  end

  def self.export_owners
    File.open('owners.txt', 'w') do |f|
      cc = Owner.all.map{ |c| "#{c.name.first} (Empresa)\t#{c.cnpj}" }.uniq
      ss = Share.all.map{ |c| c.name.first }.uniq
      f.write((cc+ss).sort.join("\n"))
    end
  end

end
