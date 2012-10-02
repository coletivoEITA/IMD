module CalculationHelper

  def self.calculate_owners_value(balance_reference_date = '2011-12-31', attr = :revenue, share_type = :on)
    Owner.set({}, "own_#{attr}" => 0)
    Owner.set({}, "indirect_#{attr}" => 0)
    Owner.set({}, "total_#{attr}" => 0)
    OwnerGroup.set({}, "own_#{attr}" => 0)
    OwnerGroup.set({}, "indirect_#{attr}" => 0)
    OwnerGroup.set({}, "total_#{attr}" => 0)
    OwnerGroup.each do |o|
      pp o
      o.calculate_value(balance_reference_date, attr, share_type)
    end
  end

end
