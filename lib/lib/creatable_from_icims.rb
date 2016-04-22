module CreatableFromICIMS

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def new_from_icims(obj)
      assert_icims(obj)
      new usable_attributes(obj)
    end

    def create_from_icims(obj)
      assert_icims(obj)
      record = new_from_icims(obj)
      record.save!
      record.reload
    end

    def assert_icims(obj)
      class_name = obj.class.name
      unless class_name.include? 'ICIMS'
        raise ArgumentError, "must be an ICIMS resource, but was #{class_name}"
      end
    end

    def usable_attributes(obj)
      canon = self.column_names
      obj.attributes.select { |k, v| canon.include?(k.to_s) }
    end
  end

end
