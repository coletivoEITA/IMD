module ExportHelper

  def self.export_owners_rankings
    def self.export_raking(attr = :revenue, share_type = :on)
      CalculationHelper.calculate_owners_value attr, share_type
      owners = Owner.all(:order => "total_#{attr}".to_sym.desc)

      FasterCSV.open("db/#{attr}-ranking-#{share_type.uppercase}-shares.csv", "w") do |csv|
        csv << ['nome', 'razão social', 'cnpj',
                'valor próprio', 'valor indireto', 'valor total',
                'empresas controladas']

        owners.each do |owner|
          controlled_companies = owner.controlled_companies(share_type).collect(&:name).sort.join(', ')

          csv << [owner.name, owner.formal_name, owner.cgc.first,
                  owner.send("own_#{attr}"), owner.send("indirect_#{attr}"), owner.send("total_#{attr}"),
                  controlled_companies]
        end
      end
    end

    export_raking :patrimony, :on
    export_raking :patrimony, :all
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
