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
      raise ArgumentError unless obj.class.name.include? 'ICIMS'
    end

    def usable_attributes(obj)
      canon = self.column_names
      obj.attributes.select { |k, v| canon.include?(k.to_s) }
    end
  end

end
