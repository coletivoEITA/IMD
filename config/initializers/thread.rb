class Thread

  def self.join_to_limit(limit = 10)
    i = 0
    list = Thread.list
    to_join = list.size - limit
    Thread.list.each do |t|
      next if t == Thread.current
      break if i > to_join
      i += 1
      t.join
    end
  end

  def self.join_all
    Thread.list.each{ |t| t.join if t != Thread.current }
  end

  def self.count
    Thread.list.size-1
  end

end
