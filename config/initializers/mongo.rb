MongoMapper.database = "imd-#{Rails.env}"

Owner.ensure_index :cnpj
Owner.ensure_index :cnpj_root
Owner.ensure_index :classes
Owner.ensure_index :naics
Owner.ensure_index :name
Owner.ensure_index :formal_name
Owner.ensure_index :name_d
Owner.ensure_index :formal_name_d

CompanyShareholder.ensure_index [[:company_id, 1], [:type, 1], [:reference_date, 1]]
CompanyShareholder.ensure_index :owner_id
CompanyShareholder.ensure_index :company_id
CompanyShareholder.ensure_index :name
CompanyShareholder.ensure_index :type
CompanyShareholder.ensure_index :reference_date

Balance.ensure_index :reference_date
Balance.ensure_index :owner_id
