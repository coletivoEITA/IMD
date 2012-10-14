# coding: UTF-8

module CalculationHelper

  def self.calculate_owners_value(attr = :revenue, balance_reference_date = $balance_reference_date, share_reference_date = $share_reference_date)
    Owner.set({}, "own_#{attr}" => 0)
    Owner.set({}, "indirect_#{attr}" => 0)
    Owner.set({}, "total_#{attr}" => 0)
    Owner.each do |o|
      o.calculate_value(attr, balance_reference_date, share_reference_date)
    end
  end

end
