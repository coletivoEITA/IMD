module ImportHelper

  CSVColumns = ActiveSupport::OrderedHash[
    'Nome', :name,
    'Classe', nil,
    'CNPJ', :cnpj,
    'Pais Sede', nil,
    'Ativo /|Cancelado', nil,
    'ID da|empresa', nil,
    'Setor NAICS|ult disponiv', nil,
    'Setor|Economática', nil,
    'Tipo de Ativo', nil,
    'Bolsa', nil,
    'Código', nil,
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
    CSVColumns[header]
  end

  def self.column_to_field(csv, column_index)
    header = csv.headers[column_index]
    header_to_field(header)
  end

  def self.import_csv(file, date)
    csv = FasterCSV.table file, :headers => true, :header_converters => nil, :converters => nil

    csv.each_with_index do |row, i|
      company = Company.new
      balance = nil
      shareholder = nil

      row.each do |header, value|
        field = header_to_field(header).to_s
        next if field.blank?

        balance = company.balances.build(:period => date) if field == 'balance_months'
        if field =~ /shareholder_(.+)_(.+)_name/
          company.company_shareholders << shareholder if shareholder and shareholder.valid?
          shareholder = CompanyShareholder.new(:period => date, :type => $1)
        end

        if field.starts_with?('balance')
          balance.send "#{$1}=", value if field =~ /balance_(.+)/
        elsif field.starts_with?('shareholder')
          shareholder.send "#{$3}=", value if field =~ /shareholder_(.+)_(.+)_(.+)/
        else
          company.send "#{field}=", value
        end
      end

      company.save
    end
  end


end
