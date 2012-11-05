module StockCodeHelper

  def self.base(code)
    code =~ /([a-z]+)/i
    $1
  end

end
