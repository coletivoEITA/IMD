module ExportHelper

  def self.export_owners_rankings(balance_reference_date = '2011-12-31', share_reference_date = '2012-09-05')

    def self.export_raking(attr = :revenue, balance_reference_date = '2011-12-31', share_reference_date = '2012-09-05')

      #CalculationHelper.calculate_owners_value attr, balance_reference_date, share_reference_date
      owners = Owner.order("total_#{attr}".to_sym.desc).all

      FasterCSV.open("db/#{attr}-ranking.csv", "w") do |csv|
        csv << ['i', 'controlada?', 'nome', 'razão social', 'cnpj',
                'valor da empresa i pela Exame (vendas)', 'valor da empresa i pela Economatica (vendas)',
                'valor indireto (das empresas em que i tem participação)', 'valor total (valor da empresa i + valor indireto)',
                'indicador de poder da empresa i', 'fonte dos dados da empresa i',
                'poder direto - controle', 'poder direto - parcial',
                'poder indireto - controle', 'poder indireto - parcial',
                'composição acionária direta', 'Estatal ou Privada?']

        total = owners.sum(&"total_#{attr}".to_sym)

        owners.each_with_index do |owner, i|
          owners_shares = owner.owners_shares.on.with_reference_date(share_reference_date).all
          owned_shares = owner.owned_shares.on.with_reference_date(share_reference_date).all

          controlled = owners_shares.first
          controlled = (controlled and controlled.control?) ? 'sim' : ''

          exame_value = owner.balances.exame.first
          exame_value = exame_value.nil? ? '0.00' : (exame_value.value(attr)/1000000).c
          exame_value = '-' if exame_value = '0.00'
          economatica_value = owner.balances.economatica.first
          economatica_value = economatica_value.nil? ? '0.00' : (economatica_value.value(attr)/1000000).c
          economatica_value = '-' if economatica_value == '0.00'

          indirect_value = owner.send("indirect_#{attr}").c
          indirect_value = '-' if indirect_value == '0.00'
          total_value = owner.send("total_#{attr}").c
          total_value = '-' if total_value == '0.00'
          index_value = total_value == '-' ? '-' : ((total_value.to_f / total)*1000).c

          power_direct_control = owned_shares.select{ |s| s.control? }.map do |s|
            "#{s.company.name} (#{s.percentage.c}%)"
          end.join(' ')
          power_direct_parcial = owned_shares.select{ |s| s.parcial? }.map do |s|
            "#{s.company.name} (#{s.percentage.c}%)"
          end.join(' ')

          power_indirect_control = owner.indirect_total_controlled_companies(share_reference_date).join(' ')
          power_indirect_parcial = owner.indirect_parcial_controlled_companies(share_reference_date).join(' ')

          shareholders = owners_shares.select{ |s| s.percentage }.map do |s|
            "#{s.owner.name} (#{s.percentage.c}%)"
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

    export_raking :revenue, '2011-12-31', '2012-09-05'
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
