# coding: UTF-8

class Float

  def c digits = 2
    return self.to_i.to_s if self == self.to_i
    v = self.zero? ? '-' : ("%.#{digits}f" % self).gsub('.', ',')
    v
  end

end
