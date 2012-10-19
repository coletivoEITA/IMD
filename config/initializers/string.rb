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

  def to_utf8(encoding = 'iso8859-1')
    if RUBY_VERSION >= "1.9"
      self.force_encoding(encoding).encode 'UTF-8'
    else
      Iconv.conv "UTF8", encoding, self
    end
  end

  def transliterate
    ActiveSupport::Inflector.transliterate(self)
  end

  CompanyNatureSuffixes = ['s.a|s/a|sa', 's.c|s/c|sc', 'ltda', 'ltd', 'inc', 'gmbh']

  def remove_company_nature
    p = Proc.new do |string|
      CompanyNatureSuffixes.inject(string) do |string, nature|
        string.gsub /\b(#{nature})\.?$/i, ''
      end.strip
    end
    string = p.call self
    # there are cases where two natures appears
    string = p.call string
  end

  def remove_symbols
    self.gsub /[^a-z0-9\s]/i, ''
  end

  def name_normalization
    self.squish.remove_company_nature.transliterate.remove_symbols.downcase
  end

end

