require 'ostruct'

module Ostructable
  refine Hash.singleton_class do

    def to_ostructs(obj, memo={})
      return obj unless obj.is_a? Hash
      os = memo[obj] = OpenStruct.new
      obj.each { |k,v| os.send("#{k}=", memo[v] || to_ostructs(v, memo)) }
      os
    end

  end
end
