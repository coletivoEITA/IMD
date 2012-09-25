module CgcHelper

  def self.extract_cnpj_root(cnpj)
    cnpj[0..-7] if cnpj
  end

  def self.cnpj?(cgc)
    return false if cgc.nil?
    cgc == '191' || (cgc.size >= 12 && cgc.size <= 14)
  end

  def self.cpf?(cgc)
    return false if cgc.nil?
    cgc.size == 11
  end

end
