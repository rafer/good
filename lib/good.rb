class Good
  VERSION = "0.1.4"

  class Value
    def self.new(*members, &block)
      Good.generate(false, *members, &block)
    end
  end

  class Record
    def self.new(*members, &block)
      Good.generate(true, *members, &block)
    end
  end

  def self.validate_constructor_attributes(attributes, allowed)
    if (unrecognized = attributes.keys.map(&:to_sym) - allowed).any?
      raise ArgumentError, "Unrecognized parameter(s): #{unrecognized.join(', ')}"
    end
  end

  def self.generate(mutable, *members, &block)
    Class.new do
      mutable ? attr_accessor(*members) : attr_reader(*members)

      const_set(:MEMBERS, members.map(&:to_sym).freeze)

      def self.coerce(coercable)
        case coercable
        when self then coercable
        when Hash then new(coercable)
        else raise TypeError, "Unable to coerce #{coercable.class} into #{self}"
        end
      end


      if mutable
        def initialize(attributes = {})
          Good.validate_constructor_attributes(attributes, self.class::MEMBERS)
          attributes.each { |k, v| send("#{k}=", v) }
        end
      else
        def initialize(attributes = {})
          Good.validate_constructor_attributes(attributes, self.class::MEMBERS)
          attributes.each { |k, v| instance_variable_set(:"@#{k}", v) }
        end
      end

      def attributes
        {}.tap { |h| self.class::MEMBERS.each { |m| h[m] = send(m) } }
      end

      def members
        self.class::MEMBERS.dup
      end

      def values
        self.class::MEMBERS.map { |m| send(m) }
      end

      def merge(attributes={})
        self.class.new(self.attributes.merge(attributes))
      end

      def ==(other)
        other.is_a?(self.class) && attributes == other.attributes
      end

      def eql?(other)
        self == other
      end

      def hash
        attributes.hash
      end

      class_eval(&block) if block
    end
  end
end

