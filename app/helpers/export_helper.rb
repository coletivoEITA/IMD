module ExportHelper

  def self.export_owners_rankings
    def self.export_raking(attr = :revenue, share_type = :on)
      CalculationHelper.calculate_owners_value attr, share_type
      owners = Owner.all(:order => "total_#{attr}".to_sym.desc)

      FasterCSV.open("db/#{attr}-ranking-#{share_type.to_s.upcase}-shares.csv", "w") do |csv|
        csv << ['nome', 'razão social', 'cnpj',
                'valor próprio', 'valor indireto', 'valor total', 'índice', 'fonte',
                'controlador majoritário', 'empresas controladas']

        total = owners.sum(&"total_#{attr}".to_sym)

        owners.each do |owner|
          balance = owner.balances.first
          source = balance ? balance.source : '-'

          own_value = owner.send("own_#{attr}")
          indirect_value = owner.send("indirect_#{attr}")
          total_value = owner.send("total_#{attr}")
          own_value = '-' if own_value.zero?
          indirect_value = '-' if indirect_value.zero?
          total_value = '-' if total_value.zero?

          controlled_companies = owner.owned_shares_by_type(share_type).map do |s|
            "#{s.company.name} (#{s.percentage}%)"
          end.join(' ')

          controller = owner.owners_shares.on.order(:percentage.desc).first
          controller = "#{controller.name} (#{controller.percentage}%)" if controller

          index_value = total_value == '-' ? '-' : (total_value / total)*1000

          csv << [owner.name, owner.formal_name, owner.cgc.first,
                  own_value, indirect_value, total_value, index_value, source,
                  controller, controlled_companies]
        end
      end
    end

    export_raking :total_active, :on
    export_raking :revenue, :on
  end

  def self.export_owners
    File.open('owners.txt', 'w') do |f|
      cc = Owner.all.map{ |c| "#{c.name} (Empresa)\t#{c.cnpj}" }.uniq
      ss = Share.all.map{ |c| c.name }.uniq
      f.write((cc+ss).sort.join("\n"))
    end
  end

end
