module CalculationHelper

  def self.calculate_owners_revenue
    Owner.set({:direct_revenue => 0}, {:indirect_revenue => 0}, {:total_revenue => 0})
    Owner.each do |o|
      o.calculate_revenue
    end
  end

end
