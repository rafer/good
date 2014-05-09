class Strukt
  VERSION = "0.0.4"

  include Enumerable

  def self.new(*members)
    Class.new do
      attr_accessor *members

      include Enumerable
      
      const_set(:MEMBERS, members.dup.freeze)

      def self.coerce(coercable)
        case coercable
        when self then coercable
        when Hash then new(coercable)
        else raise TypeError, "Unable to coerce #{coercable.class} into #{self}"
        end
      end
      
      def initialize(params = {})
        params.each { |k, v| send("#{k}=", v) }
      end

      def ==(other)
        other.is_a?(self.class) && to_hash == other.to_hash
      end

      def eql?(other)
        self == other
      end
      
      def hash
        to_hash.hash
      end

      def to_hash
        {}.tap { |h| self.class::MEMBERS.each { |m| h[m] = send(m) } }
      end

      def each(*args, &block)
        to_hash.each(*args, &block)
      end
    end
  end
end

