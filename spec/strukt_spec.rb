require "bundler/setup"

describe Strukt do
  class Person < Strukt.new(:name, :age)
  end

  describe "#initialize" do
    it "accepts values via hash in the constructor" do
      person = Person.new(:name => "Bob")
      expect(person.name).to eq("Bob")
    end

    it "accepts string keys" do
      person = Person.new("name" => "Bob")
      expect(person.name).to eq("Bob")
    end

    it "allows 0 argument construction" do
      person = Person.new
    end
  end

  describe "#each" do
    it "is Enumerable" do
      expect(Person.new).to be_a(Enumerable)
    end
  
    it "enumerates over key-value pairs" do
      bob = Person.new(:name => "Bob", :age => 50)
      expect(bob.entries).to eq([[:name, "Bob"], [:age, 50]])
    end
  end
  
  describe "#==" do
    it "is true if all the parameters are ==" do
      bob_1 = Person.new(:name => "Bob", :age => 50)
      bob_2 = Person.new(:name => "Bob", :age => 50)
      
      expect(bob_1).to eq(bob_2)
    end
    
    it "is false if any attributes are not #==" do
      bob = Person.new(:name => "Bob", :age => 50)
      ted = Person.new(:name => "Ted", :age => 50)
      
      expect(bob).not_to eq(ted)
    end
    
    it "is false if the other object is not of the same class" do
      bob = Person.new(:name => "Bob", :age => 50)
      alien_bob = Struct.new(:name, :age).new("Bob", 50)
      
      expect(bob).not_to eq(alien_bob)
    end
  end
  
  describe "::MEMBERS" do
    it "is the list of member variables" do
      expect(Person::MEMBERS).to eq([:name, :age])
    end
  end
  
  describe "#to_hash" do
    it "returns the struct as a hash" do
      person = Person.new(:name => "bob", :age => 50)
      expect(person.to_hash).to eq({:name => "bob", :age => 50})
    end
    
    it "is frozen" do
      expect { Person::MEMBERS << :height }.to raise_error(/can't modify frozen/)
    end
  end
end
