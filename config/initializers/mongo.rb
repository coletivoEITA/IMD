# coding: UTF-8

#MongoMapper.connection = Mongo::Connection.new("localhost", 27017, :pool_size => 100, :pool_timeout => 500)
MongoMapper.database = "imd-#{Rails.env}"

Owner.ensure_index :source
Owner.ensure_index :cgc
Owner.ensure_index :cnpj_root
Owner.ensure_index :classes
Owner.ensure_index :naics
Owner.ensure_index :name
Owner.ensure_index :formal_name
Owner.ensure_index :name_n
Owner.ensure_index :formal_name_n
Owner.ensure_index :asclaras_id
Owner.ensure_index [[:name, 1], [:asclaras_id, 1]]

NameEquivalence.ensure_index :name
NameEquivalence.ensure_index :synonymous
NameEquivalence.ensure_index [[:name, 1], [:synonymous, 1]]
NameEquivalence.ensure_index [[:name, 1], [:synonymous, 1], [:source, 1]]
NameEquivalence.ensure_index [[:synonymous, 1], [:source, 1]]

Share.ensure_index :source
Share.ensure_index :owner_id
Share.ensure_index :company_id
Share.ensure_index :name
Share.ensure_index :sclass
Share.ensure_index :reference_date
Share.ensure_index [[:name, 1], [:company_id, 1], [:source, 1], [:sclass, 1], [:reference_date, 1]]

Balance.ensure_index :reference_date
Balance.ensure_index :owner_id
Balance.ensure_index :source
Balance.ensure_index [[:company_id, 1], [:source, 1], [:reference_date, 1]]

CompanyMember.ensure_index :member_id
CompanyMember.ensure_index :company_id

Donation.ensure_index :candidacy_id
Donation.ensure_index :grantor_id
Donation.ensure_index :value
Donation.ensure_index :type

Candidacy.ensure_index :candidate_id
Candidacy.ensure_index :year
Candidacy.ensure_index :asclaras_id
Candidacy.ensure_index [[:candidate_id, 1], [:year, 1]]
Candidacy.ensure_index [[:candidate_id, 1], [:year, 1], [:asclaras_id, 1]]

# for sorting
Owner.ensure_index :own_revenue
Owner.ensure_index :indirect_revenue
Owner.ensure_index :total_revenue
Owner.ensure_index :own_patrimony
Owner.ensure_index :indirect_patrimony
Owner.ensure_index :total_patrimony
