# coding: UTF-8

module CheckHelper

  def self.check_more_than_100percent_shares(share_type = 'ON', share_reference_date = '2012-09-05')
    Owner.all.map do |o|
      shares = o.owners_shares.where(:sclass => share_type).with_reference_date(share_reference_date).all
      sum = shares.sum{ |s| s.percentage.nil? ? 0 : s.percentage }
      o if sum > 100
    end.compact
  end

  def self.check_similar_balance(attr = :revenue, balance_reference_date = '2011-12-31')
    value_field = "own_#{attr}".to_sym
    owners = Owner.where(value_field.ne => 0).order(value_field.asc).all
    max_percentage_diff = 0.1

    last = owners.first
    last_value = last.value(attr, balance_reference_date)
    owners.shift # remove first

    CSV.open("db/similiar-balance-#{attr}.csv", "w") do |csv|
      csv << ['diff', 'name', 'name']

      owners.each do |owner|
        value = owner.value(attr, balance_reference_date)
        diff = ((value / last_value) - 1) * 100

        csv << [diff, last.name, owner.name] if diff < max_percentage_diff

        last = owner
        last_value = value
      end
    end
    true
  end

  def self.check_levenshtein
    attr = :name
    CSV.open("db/levenshtein-#{attr}-distance.csv", "w") do |csv|
      csv << ['levenshtein', 'nome 1', 'nome 2']

      values = Owner.all.collect(&attr)
      pairs = {}
      values.each do |a|
        values.each do |b|
          next if a == b
          next if pairs[[a,b]] or pairs[[b,a]]
          d = Levenshtein.distance a, b
          pairs[[a,b]] = d
        end
      end

      pairs.each do |(a,b), d|
        csv << [d, a, b]
      end
    end
  end

  def self.check_same_words
    attr = :name
    CSV.open("db/#{attr.to_s.pluralize}-with-same-words.csv", "w") do |csv|
      csv << ['nome 1', 'nome 2', 'palavras comuns']

      values = Owner.all.collect(&attr)
      pairs = {}
      values.each do |a|
        values.each do |b|
          next if a == b
          next if pairs[[a,b]] or pairs[[b,a]]

          a_words = a.filter_normalization.split(' ')
          b_words = b.filter_normalization.split(' ')
          c_words = a_words.select{ |a| b_words.find_index(a) }
          next if c_words.empty?
          pairs[[a,b]] = c_words.join(', ')
        end
      end

      pairs.each do |(a,b), words|
        csv << [a, b, words]
      end
    end
  end

end
