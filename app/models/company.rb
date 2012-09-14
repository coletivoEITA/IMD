class Company

  include MongoMapper::Document

  key :name, String
  key :cnpj, String
  key :shares_quantity, Integer

  many :balances, :dependent => :destroy_all
  many :company_shareholders, :dependent => :destroy_all

end

