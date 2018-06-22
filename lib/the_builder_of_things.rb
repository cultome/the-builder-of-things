require "the_builder_of_things/version"
require 'active_support/core_ext/string'
require 'delegate'

module TheBuilderOfThings
  class Thing
    attr_accessor :name

    def initialize(name=nil)
      @name = name
    end

    def is_a
      BooleanPropertyBuilder.new(self)
    end

    def is_not_a
      BooleanPropertyBuilder.new(self, negated: true)
    end

    def is_the
      PropertyBuilder.new(self)
    end

    alias :being_the :is_the
    alias :and_the :is_the

    def has(things)
      if things == 1
        nested_object = Thing.new
      else
        objs = (1..things).map{ Thing.new }
        nested_object = Things.new(objs)
      end

      ThingBuilder.new(self, nested_object)
    end

    alias :having :has
    alias :with :has

    def can
      BehaviorBuilder.new(self)
    end

  end

  class BehaviorBuilder
    def initialize(parent)
      @parent = parent
    end

    def method_missing(mtd, *args, &blk)
      parent = @parent
      calls = []
      @parent.define_singleton_method(mtd) do |*params|
        result = parent.instance_exec(*params, &blk)
        calls << result
        result
      end

      unless args.empty?
        @parent.define_singleton_method(args.first) do
          calls
        end
      end
    end
  end

  class ThingBuilder
    def initialize(parent, nested)
      @parent = parent
      @nested = nested
    end

    def prepare(instance, accesor_name)
      instance.name = accesor_name
      instance.define_singleton_method "#{accesor_name}?" do
        true
      end
    end

    def method_missing(mtd, *args, &blk)
      nested = @nested
      accesor_name = mtd.to_s.singularize

      if nested.respond_to? :map
        nested.map{|n| prepare(n, accesor_name) }
      else
        prepare(nested, accesor_name)
      end

      @parent.define_singleton_method mtd do
        nested
      end

      @nested
    end
  end

  class Things < SimpleDelegator
    def each(&blk)
      self.to_a.each do |thing|
        thing.instance_eval(&blk)
      end
    end

    def is_a?(clazz)
      return true if clazz == Array
      super
    end
  end

  class BooleanPropertyBuilder
    def initialize(parent, props={negated: false})
      @parent = parent
      @negated = props[:negated]
    end

    def method_missing(mtd, *args, &blk)
      response = !@negated
      @parent.define_singleton_method "#{mtd}?" do
        response
      end

      @parent
    end
  end

  class PropertyBuilder
    def initialize(parent, props={key: nil})
      @parent = parent
      @key = props.fetch(:key, nil)
    end

    def method_missing(mtd, *args, &blk)
      return PropertyBuilder.new(@parent, key: mtd) if not @key

      @parent.define_singleton_method "#{@key}" do
        mtd.to_s
      end

      @parent
    end
  end
end
