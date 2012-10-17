# coding: UTF-8

require 'spec_helper'

describe Owner do

  it 'calculate total value case 3' do
    owners = create_owners_and_shares 'B' => [['A', 10]], 'C' => [['B', 10]],
      'D' => [['C', 10], ['E', 10], ['F', 10]],
      'E' => [['D', 10]], 'F' => [['D', 10]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_value }

    expect(owners['A'].total_revenue).to eq(111.12222)
    expect(owners['B'].total_revenue).to eq(111.2222)
    expect(owners['C'].total_revenue).to eq(112.22200000000001)
    expect(owners['D'].total_revenue).to eq(122.22)
    expect(owners['E'].total_revenue).to eq(112.11)
    expect(owners['F'].total_revenue).to eq(112.11)
  end

  it 'calculate total value case 0' do
    owners = create_owners_and_shares 'C' => [['D', 20]],
      'A' => [['B', 40], ['C', 30]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_value }

    expect(owners['A'].total_revenue).to eq(100)
    expect(owners['B'].total_revenue).to eq(140)
    expect(owners['C'].total_revenue).to eq(130)
    expect(owners['D'].total_revenue).to eq(126)
  end

  it 'calculate total value case 1' do
    owners = create_owners_and_shares 'C' => [['B', 10]],
      'B' => [['A', 30], ['C', 30]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_value }

    expect(owners['A'].total_revenue).to eq(133.9)
    expect(owners['B'].total_revenue).to eq(113)
    expect(owners['C'].total_revenue).to eq(133)
  end

  it 'calculate total value case 2' do
    owners = create_owners_and_shares 'B' => [['A', 10]], 'C' => [['A', 10]],
      'D' => [['B', 10], ['C', 10]], 'E' => [['D', 10]]

    create_balances owners.values.map{ |o| [o, 100] }
    owners.values.each{ |o| o.calculate_value }

    expect(owners['A'].total_revenue).to eq(122.2)
    expect(owners['B'].total_revenue).to eq(111)
    expect(owners['C'].total_revenue).to eq(111)
    expect(owners['D'].total_revenue).to eq(110)
    expect(owners['E'].total_revenue).to eq(100)
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
      owner.balances.create! :revenue => 100, :reference_date => $balance_reference_date, :source => 'Economatica'
    end
  end

end


