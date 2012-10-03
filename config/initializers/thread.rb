class Thread

  def self.join_all
    Thread.list.each{ |t| t.join if t != Thread.current }
  end

  def self.count
    Thread.list.size-1
  end

end
