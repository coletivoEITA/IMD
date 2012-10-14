# coding: UTF-8

module DateHelper

  def self.date_from_brazil(date)
    Date.strptime date, '%d/%m/%Y'
  end

  def self.time_from_ordered(date)
    Time.strptime date, '%Y-%m-%d'
  end

end
