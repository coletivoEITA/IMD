# coding: UTF-8

require 'spec_helper'

describe Owner do

  it 'calculate total value case 4' do
    owners = create_owners_and_shares 'B' => [['A', 51], ['C', 10]], 'C' => [['A', 10], ['B', 10]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_values }

    expect(owners['A'].total_revenue).to eq(220)
    expect(owners['B'].total_revenue).to eq(110)
    expect(owners['C'].total_revenue).to eq(100)
  end

  it 'calculate total value case 3' do
    owners = create_owners_and_shares 'B' => [['A', 27.09]], 'C' => [['B', 45.01]],
      'D' => [['C', 33.03], ['E', 14.3], ['F', 49.87]],
      'E' => [['D', 3.75]], 'F' => [['D', 11.27]]

    create_balances [[owners['A'], 1596.33], [owners['B'], 828.99], [owners['C'], 5679.12],
                     [owners['D'], 333.33], [owners['E'], 668.71], [owners['F'], 2546.7]]
    owners.values.each{ |o| o.calculate_values }

    pp owners['A'].total_revenue
    pp owners['B'].total_revenue
    pp owners['C'].total_revenue
    pp owners['D'].total_revenue
    pp owners['E'].total_revenue
    pp owners['F'].total_revenue
    expect(owners['A'].total_revenue).to eq(2583.03964940368)
    expect(owners['B'].total_revenue).to eq(3642.33905280057)
    expect(owners['C'].total_revenue).to eq(6250.49778449361)
    expect(owners['D'].total_revenue).to eq(1729.8752179643)
    expect(owners['E'].total_revenue).to eq(733.32638566903)
    expect(owners['F'].total_revenue).to eq(2739.14571845705)
  end

  it 'calculate total value case 0' do
    owners = create_owners_and_shares 'C' => [['D', 20]],
      'A' => [['B', 40], ['C', 30]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_values }

    expect(owners['A'].total_revenue).to eq(100)
    expect(owners['B'].total_revenue).to eq(140)
    expect(owners['C'].total_revenue).to eq(130)
    expect(owners['D'].total_revenue).to eq(126)
  end

  it 'calculate total value case 1' do
    owners = create_owners_and_shares 'C' => [['B', 33]],
      'B' => [['A', 48], ['C', 29]]

    create_balances [[owners['A'], 700], [owners['B'], 200], [owners['C'], 945]]
    owners.values.each{ |o| o.calculate_values }

    expect(owners['A'].total_revenue).to eq(954.8752)
    expect(owners['B'].total_revenue).to eq(530.99)
    expect(owners['C'].total_revenue).to eq(1093.4365)
  end

  it 'calculate total value case 2' do
    owners = create_owners_and_shares 'B' => [['A', 37.5]], 'C' => [['A', 22.9]],
      'D' => [['B', 15.76], ['C', 20.17]], 'E' => [['D', 5.67]]

    create_balances [[owners['A'], 938.2], [owners['B'], 379.03],
                     [owners['C'], 777.77], [owners['D'], 666.66], [owners['E'], 1987.12]]
    owners.values.each{ |o| o.calculate_values }

    expect(owners['A'].total_revenue).to eq(1340.5006590033672)
    expect(owners['B'].total_revenue).to eq(501.8523613504)
    expect(owners['C'].total_revenue).to eq(934.9608012968)
    expect(owners['D'].total_revenue).to eq(779.329704)
    expect(owners['E'].total_revenue).to eq(1987.12)
  end

  protected

  def create_owners_and_shares data = {}
    data.each do |company, owners|
      company = Owner.first_or_new 'Economatica', :name => company
      company.save!

      owners.each do |owner, percentage|
        company.owners_shares.create! :name => owner, :percentage => percentage,
          :sclass => 'ON', :reference_date => $share_reference_date, :source => 'Economatica'
      end
    end

    owners = {}
    Owner.each{ |o| owners[o.name] = o }

    owners
  end

  def create_balances data = {}
    data.each do |owner, revenue|
      owner.balances.create! :revenue => revenue, :reference_date => $balance_reference_date, :source => 'Economatica'
    end
  end

end


