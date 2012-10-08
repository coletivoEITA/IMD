# coding: UTF-8

require 'iconv' unless RUBY_VERSION >= "1.9"

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
      Iconv.conv('ASCII//IGNORE', 'UTF8', self)
    end
  end

  def transliterate
    ActiveSupport::Inflector.transliterate(self)
  end

  def filter_normalization
    self.transliterate.gsub(/(s.a|s\/a|sa)\.?/i, '').strip.squish.downcase
  end

end

