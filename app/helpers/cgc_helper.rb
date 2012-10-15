# coding: UTF-8

module CgcHelper

  def self.parse(cgc)
    cgc = self.remove_non_numbers(cgc)
    if cgc.size > 11
      '%014d' % cgc.to_i
    else
      '%011d' % cgc.to_i
    end
  end

  def self.format(cgc)
    '%s/%s-%s' % [cgc[0..7], cgc[8..11], cgc[12..13]]
  end

  def self.extract_cnpj_root(cnpj)
    cnpj[0..-7] if cnpj
  end

  def self.numbers_only?(cgc)
    cgc =~ /^\d*$/
  end

  def self.cnpj?(cgc)
    return false if cgc.nil?
    self.numbers_only?(cgc) && cgc.size == 14
  end

  def self.cpf?(cgc)
    return false if cgc.nil?
    self.numbers_only?(cgc) && cgc.size == 11
  end

  def self.valid?(cgc)
    cgc.blank? || cgc == 'foreign' || self.cnpj?(cgc) || self.cpf?(cgc)
  end

  def self.remove_non_numbers(cgc)
    cgc.gsub(/[^\d]/, '')
  end

end
