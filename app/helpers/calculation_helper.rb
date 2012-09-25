module CalculationHelper

  def self.calculate_owners_value(attr = :revenue, share_type = :on)
    Owner.set({}, "own_#{attr}" => 0)
    Owner.set({}, "indirect_#{attr}" => 0)
    Owner.set({}, "total_#{attr}" => 0)
    Owner.each do |o|
      pp o
      o.calculate_value(attr, share_type)
    end
  end

end
