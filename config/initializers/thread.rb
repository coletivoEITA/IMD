class Thread

  @main_thread = Thread.current

  def self.main
    @main_thread
  end

  def self.join_to_limit(limit = 10, exclude = [])
    i = 0
    list = Thread.list.reject{ |t| exclude.include?(t) }
    to_join = list.size - limit
    list.each do |t|
      next if t == Thread.current
      break if i > to_join
      i += 1
      t.join
    end
  end

  def self.join_all(exclude = [])
    Thread.list.each{ |t| t.join unless exclude.include?(t) or t == Thread.current }
  end

  def self.count
    Thread.list.size-1
  end

end
