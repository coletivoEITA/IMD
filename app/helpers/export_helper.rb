module ExportHelper

  def self.export_owners_rankings(share_reference_date = '2012-09-05', balance_reference_date = '2011-12-31')

    def self.export_raking(share_reference_date = '2012-09-05', balance_reference_date = '2011-12-31', attr = :revenue, share_type = :on)

      CalculationHelper.calculate_owners_value balance_reference_date, attr, share_type
      owners = Owner.order("total_#{attr}".to_sym.desc).all

      FasterCSV.open("db/#{attr}-ranking-#{share_type.to_s.upcase}-shares.csv", "w") do |csv|
        csv << ['i', 'controlada?', 'nome', 'razão social', 'cnpj',
                'valor da empresa i pela Exame (vendas)', 'valor da empresa i pela Economatica (vendas)',
                'valor indireto (das empresas em que i tem participação)', 'valor total (valor da empresa i + valor indireto)',
                'indicador de poder da empresa i', 'fonte dos dados da empresa i',
                'poder direto - controle', 'poder direto - parcial',
                'poder indireto - controle', 'poder indireto - parcial',
                'composição acionária direta', 'Estatal ou Privada?']

        total = owners.sum(&"total_#{attr}".to_sym)

        owners.each_with_index do |owner, i|
          owners_shares = owner.owners_shares.send(share_type).with_reference_date(share_reference_date).all
          owned_shares = owner.owned_shares.send(share_type).with_reference_date(share_reference_date).all

          controlled = owners_shares.first
          controlled = (controlled and controlled.percentage > 50) ? 'sim' : ''

          exame_value = owner.balances.exame.first.value(attr).c
          exame_value = '-' if exame_value.zero?
          economatica_value = owner.balances.economatica.first.value(attr).c
          economatica_value = '-' if economatica_value.zero?

          indirect_value = owner.send("indirect_#{attr}").c
          total_value = owner.send("total_#{attr}").c
          indirect_value = '-' if indirect_value.zero?
          total_value = '-' if total_value.zero?
          index_value = total_value == '-' ? '-' : ((total_value / total)*1000).c

          power_direct_control = owned_shares.select{ |s| s.percentage > 50 }.map do |s|
            "#{s.company.name} (#{s.percentage}%)"
          end.join(' ')
          power_direct_parcial = owned_shares.select{ |s| s.percentage < 50 }.map do |s|
            "#{s.company.name} (#{s.percentage}%)"
          end.join(' ')

          power_indirect_control = ''
          power_indirect_parcial = ''

          shareholders = owners_shares.map do |s|
            "#{s.owner.name} (#{s.percentage}%)"
          end.join(' ')

          csv << [(i+1).to_s, controlled, owner.name, owner.formal_name, owner.cgc.first,
                  exame_value, economatica_value,
                  indirect_value, total_value,
                  index_value, owner.source,
                  power_direct_control, power_direct_parcial,
                  power_indirect_control, power_indirect_parcial,
                  shareholders, owner.capital_type]
        end
      end
    end

    export_raking '2012-09-05', '2011-12-31', :revenue, :on
  end

  def self.export_owners
    File.open('owners.txt', 'w') do |f|
      cc = Owner.all.map{ |c| "#{c.name} (Empresa)\t#{c.cnpj}" }.uniq
      ss = Share.all.map{ |c| c.name }.uniq
      f.write((cc+ss).sort.join("\n"))
    end
  end

end
