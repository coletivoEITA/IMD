class Donation

  include MongoMapper::Document
  timestamps!

  key :candidacy_id, ObjectId, :required => :true
  belongs_to :candidacy

  key :grantor_id, ObjectId, :required => :true
  belongs_to :grantor, :class_name => 'Owner'

  key :value, Float, :required => :true
  key :type, String

  extend MongoCaching::ClassMethods
  cache_associated :state, :from => :candidacy
  cache_associated :city, :from => :candidacy

  validates_presence_of :value
  validates_presence_of :candidacy
  validates_presence_of :grantor
  validates_uniqueness_of :grantor_id, :scope => [:candidacy_id, :value]
  validates_numericality_of :value
  validates_inclusion_of :type, :in => %w(direct committee), :allow_nil => true

  def self.grouped_by(column, options = {})
   map_function = "function() { emit( this.#{column}, 1); }"
   
   # put your logic here (not needed in my case)
   reduce_function = %Q( function(key, values) {
     return true;
   })
   
   collection.map_reduce(map_function, reduce_function, options)
 end

end
