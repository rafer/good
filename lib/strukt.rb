class Strukt
  VERSION = "0.0.1"

  include Enumerable

  class << self
    alias_method :subclass_new, :new
  end

  def self.new(*members)
    Class.new(self) do
      attr_accessor *members

      def self.new(*args, &block)
        subclass_new(*args, &block)
      end

      @members = members.dup.freeze
    end
  end

  def self.members
    @members.dup
  end
  
  def initialize(params = {})
    params.each { |k, v| send("#{k}=", v) }
  end

  def ==(other)
    other.is_a?(self.class) && to_hash == other.to_hash
  end
  
  def to_hash
    {}.tap { |h| self.class.members.each { |m| h[m] = send(m) } }
  end
  
  def each(*args, &block)
    to_hash.each(*args, &block)
  end
end
