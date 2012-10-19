# coding: UTF-8

class Float

  def c
    self.zero? ? '-' : '%.2f' % self
  end

end
