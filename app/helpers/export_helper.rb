module ExportHelper
  def self.export_companies_donations_by_party(options = {})   
    FasterCSV.open("db/companeis-donation-by-party.csv", "w") do |csv|
	  #set header
      csv << ['nome', 'razão social', 'cnpj',
			  'total doado', '% por partido']
	  #TODO:refactore - filter donation by option arguments
      Owner.all.each do |owner|
		next if owner.donations_made.count == 0
		#check if the owner is a company or a person
		next if owner.cgc.length < 14
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

  def self.export_owners_rankings
    def self.export_raking(attr = :revenue, share_type = :on)
      CalculationHelper.calculate_owners_value attr, share_type
      owners = Owner.all(:order => "total_#{attr}".to_sym.desc)

      FasterCSV.open("db/#{attr}-ranking-#{share_type.to_s.upcase}-shares.csv", "w") do |csv|
        csv << ['nome', 'razão social', 'cnpj',
                'valor próprio', 'valor indireto', 'valor total',
                'controlador majoritário', 'empresas controladas']

        owners.each do |owner|
          controlled_companies = owner.owned_shares_by_type(share_type).map do |s|
            "#{s.company.name} (#{s.percentage}%)"
          end.join(' ')

          controller = owner.controlled_owner
          controller = "#{controller.name} (#{controller.percentage}%)" if controller

          csv << [owner.name, owner.formal_name, owner.cgc.first,
                  owner.send("own_#{attr}"), owner.send("indirect_#{attr}"), owner.send("total_#{attr}"),
                  controller, controlled_companies]
        end
      end
    end

    export_raking :total_active, :on
    export_raking :total_active, :all
    export_raking :revenue, :on
    export_raking :revenue, :all
  end

  def self.export_owners
    File.open('owners.txt', 'w') do |f|
      cc = Owner.all.map{ |c| "#{c.name} (Empresa)\t#{c.cnpj}" }.uniq
      ss = Share.all.map{ |c| c.name }.uniq
      f.write((cc+ss).sort.join("\n"))
    end
  end

end
