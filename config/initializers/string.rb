class String

  def downcase
    Unicode::downcase(self)
  end

  def upcase
    Unicode::upcase(self)
  end

  def remove_non_ascii(replacement="")
    self.gsub(/[\x80-\xff]/,replacement)
  end

  def filter_normalization
    self.downcase.remove_non_ascii
  end

end

