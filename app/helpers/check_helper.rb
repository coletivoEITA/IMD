# coding: UTF-8

module CheckHelper

  def self.check_more_than_100percent_shares(share_type = 'ON', share_reference_date = '2012-09-05')
    Owner.all.map do |o|
      shares = o.owners_shares.where(:sclass => share_type).with_reference_date(share_reference_date).all
      sum = shares.sum{ |s| s.percentage.nil? ? 0 : s.percentage }
      o if sum > 100
    end.compact
  end

end
