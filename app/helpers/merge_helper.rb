# coding: UTF-8

module MergeHelper

  def self.owner dest, source
    source.balances.each{ |b| b.update_attribute :company_id, dest.id }
    source.owned_shares.each{ |s| s.update_attribute :owner_id, dest.id }
    source.owners_shares.each{ |s| s.update_attribute :company_id, dest.id }
    source.members.each{ |m| m.update_attribute :company_id, dest.id }
    source.members_of.each{ |m| m.update_attribute :member_id, dest.id }
    source.candidacies.each{ |c| c.update_attribute :candidate_id, dest.id }
    source.donations_made.each{ |d| d.update_attribute :grantor_id, dest.id }
    source.donations_received.each{ |d| d.update_attribute :candidate_id, dest.id }

    source.attributes.each{ |key, value| dest.set_value key, value }

    source.destroy
    dest
  end

end
