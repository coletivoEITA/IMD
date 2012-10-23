# coding: UTF-8

class Float

  def c(digits = 2)
    self.zero? ? '-' : ("%.#{digits}f" % self).gsub('.', ',')
  end

end
