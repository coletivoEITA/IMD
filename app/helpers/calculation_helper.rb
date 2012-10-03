# coding: UTF-8

module CalculationHelper

  def self.calculate_owners_value(attr = :revenue, balance_reference_date = '2011-12-31', share_reference_date = '2012-09-05')
    Owner.set({}, "own_#{attr}" => 0)
    Owner.set({}, "indirect_#{attr}" => 0)
    Owner.set({}, "total_#{attr}" => 0)
    Owner.each do |o|
      o.calculate_value(attr, balance_reference_date, share_reference_date)
    end
  end

end
