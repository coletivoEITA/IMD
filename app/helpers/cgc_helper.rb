module CgcHelper

  def self.extract_cnpj_root(cnpj)
    cnpj[0,8] if cnpj
  end

  def self.cnpj?(cgc)
    cgc.size == 14
  end

  def self.cpf?(cgc)
    cgc.size == 11
  end

end
