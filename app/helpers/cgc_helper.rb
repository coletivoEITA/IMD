module CgcHelper

  def self.extract_cnpj_root(cnpj)
    cnpj[0..-7] if cnpj
  end

  def self.cnpj?(cgc)
    return false if cgc.nil?
    cgc.size == 14
  end

  def self.cpf?(cgc)
    return false if cgc.nil?
    cgc.size == 11
  end

  def self.valid?(cgc)
    cgc.blank? || cgc == 'foreign' || self.cnpj?(cgc) || self.cpf?(cgc)
  end

end
