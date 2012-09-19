MongoMapper.database = "imd-#{Rails.env}"

Owner.ensure_index :cnpj, :unique => true
Owner.ensure_index :naics
Owner.ensure_index :classes
