module ExportHelper

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

          controller = owner.controller_share
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
