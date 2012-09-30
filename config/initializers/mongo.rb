MongoMapper.connection = Mongo::Connection.new("localhost", 27017, :pool_size => 100, :pool_timeout => 500)
MongoMapper.database = "imd-#{Rails.env}"

Owner.ensure_index :cgc
Owner.ensure_index :cnpj_root
Owner.ensure_index :classes
Owner.ensure_index :naics
Owner.ensure_index :name
Owner.ensure_index :formal_name
Owner.ensure_index :name_d
Owner.ensure_index :formal_name_d

Share.ensure_index [[:company_id, 1], [:type, 1], [:reference_date, 1]]
Share.ensure_index :owner_id
Share.ensure_index :company_id
Share.ensure_index :name
Share.ensure_index :type
Share.ensure_index :reference_date

Balance.ensure_index :reference_date
Balance.ensure_index :owner_id

CompanyMember.ensure_index :member_id
CompanyMember.ensure_index :company_id

Donation.ensure_index :candidacy_id
Donation.ensure_index :grantor_id
Donation.ensure_index :value
Donation.ensure_index [[:candidacy_id, 1], [:grantor_id, 1], [:value, 1]]

Candidacy.ensure_index :candidate_id
Candidacy.ensure_index :year
Candidacy.ensure_index [[:candidate_id, 1], [:year, 1]]

# for sorting
Owner.ensure_index :own_revenue
Owner.ensure_index :indirect_revenue
Owner.ensure_index :total_revenue
Owner.ensure_index :own_patrimony
Owner.ensure_index :indirect_patrimony
Owner.ensure_index :total_patrimony
