$balance_reference_date = DateHelper.time_from_ordered '2011-12-31'
$share_reference_date = DateHelper.time_from_ordered '2012-09-05'

$uniao = Owner.find_by_name 'Uniao Federal (Tesouro Nacional)'
$bndespar = Owner.first :name => /bndespar/i

