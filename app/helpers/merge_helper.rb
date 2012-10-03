# coding: UTF-8

module MergeHelper

  def self.merge_pair(dest, source)
    source.balances.each{ |b| b.update_attribute :company_id, dest.id }
    source.owned_shares.each{ |s| s.update_attribute :owner_id, dest.id }
    source.owners_shares.each{ |s| s.update_attribute :company_id, dest.id }
    source.members.each{ |m| m.update_attribute :company_id, dest.id }
    source.members_of.each{ |m| m.update_attribute :member_id, dest.id }
    source.candidacies.each{ |c| c.update_attribute :candidate_id, dest.id }
    source.donations_made.each{ |d| d.update_attribute :grantor_id, dest.id }
    source.donations_received.each{ |d| d.update_attribute :candidate_id, dest.id }

    source.cgc.each{ |cgc| dest.add_cgc cgc }

    source.destroy
  end

end
