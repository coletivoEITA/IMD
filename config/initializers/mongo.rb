MongoMapper.database = "imd-#{Rails.env}"

Owner.ensure_index :cnpj, :unique => true
Owner.ensure_index :cnpj_root, :unique => true
Owner.ensure_index :classes
Owner.ensure_index :naics
Owner.ensure_index :name
Owner.ensure_index :formal_name
Owner.ensure_index :name_d
Owner.ensure_index :formal_name_d
