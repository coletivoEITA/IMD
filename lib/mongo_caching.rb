module MongoCaching

  module ClassMethods

    # Cache a key from another method using a after_save to syncronize
    # using many association to update
    #
    #
    # Options:
    #   from:
    #   as: alias name of the cache field
    #   type: specify
    #   association: specify the method that returns the set of associated objects from source class
    #
    # Examples:
    #   cache_associated :state, :from => :grantor
    #
    def cache_associated(from_field, options)
      raise ':from not specified' if options[:from].blank?

      name = options[:as] || from_field.to_s
      from = options[:from].to_s
      from_field = from_field.to_s
      from_class = (self.associations[from.to_sym].options[:class_name] || from.camelize).constantize
      key_type = options[:type] || from_class.keys[from_field].type
      association = options[:association] || self.name.underscore.pluralize

      sync_from_proc = Proc.new do |record|
        value = record.send(from_field)
        associated = record.send(association)
        associated.each{ |i| i.update_attribute name, value }
      end
      cache_proc = Proc.new do
        value = self.send(from).send(from_field)
        self.update_attribute name, value
      end

      key name, key_type

      # instance method
      define_method "cache_#{name}", &cache_proc

      from_class.after_save &sync_from_proc

      # class method
      (class << self; self; end).send(:define_method, "cache_#{name}") do
        from_class.each &sync_from_proc
      end
    end

  end

  def cache_method method, type, &block
      sync_from_proc = Proc.new do |record|
        value = record.send(from_field)
        associated.each{ |i| i.update_attribute name, value }
      end
      cache_proc = Proc.new do
        value = self.send method
        value = block.call value if block
        self.update_attribute name, value
      end

      key "#{method}_cached", type

      define_method "cache_#{name}", &cache_proc
  end

  def cache_external association, type
    from_class = (self.associations[from.to_sym].options[:class_name] || from.camelize).constantize

    cache_method association do |value|
      if value.is_a?(Array)
        value.map{ |v| v.send :attributes }
      else
        value.send :attributes
      end
    end
  end

  module InstanceMethods


  end

end
