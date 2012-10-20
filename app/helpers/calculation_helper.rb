# coding: UTF-8

module CalculationHelper

  def self.calculate_owners_value(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)
    Owner.set({}, "own_#{attr}" => nil)
    Owner.set({}, "indirect_#{attr}" => nil)
    Owner.set({}, "total_#{attr}" => nil)
    Owner.each do |o|
      o.calculate_values attr, balance_reference_date, share_reference_date
    end
  end

end
