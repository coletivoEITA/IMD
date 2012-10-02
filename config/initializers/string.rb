# coding: UTF-8

class String

  def downcase
    Unicode::downcase(self)
  end

  def upcase
    Unicode::upcase(self)
  end

  def remove_non_ascii(replacement="")
    if RUBY_VERSION >= "1.9"
      encoding_options = {
        :invalid           => :replace,  # Replace invalid byte sequences
        :undef             => :replace,  # Replace anything not defined in ASCII
        :replace           => '',        # Use a blank for those replacements
        :universal_newline => true       # Always break lines with \n
      }
      self.encode Encoding.find('ASCII'), encoding_options
    else
      #self.gsub(/[\x80-\xff]/,replacement)
    end
  end

  def filter_normalization
    self.gsub('S/A', '').gsub('S.A.', '').downcase.remove_non_ascii
  end

end

