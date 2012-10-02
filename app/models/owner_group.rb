class OwnerGroup

  include MongoMapper::Document
  timestamps!

  key :name, String, :unique => true, :required => true

  many :owners, :class_name => 'Owner', :foreign_key => :group_id

  def method_missing(method, *args, &block)
    if owners.first.respond_to?(method)
      owners.map{ |o| o.send(method, *args, &block) }
    else
      super
    end
  end

end
