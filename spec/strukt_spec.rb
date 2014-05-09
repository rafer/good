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

  describe "#eql" do
    it "is true if all the parameters are ==" do
      bob_1 = Person.new(:name => "Bob", :age => 50)
      bob_2 = Person.new(:name => "Bob", :age => 50)
      
      expect(bob_1).to eql(bob_2)
    end
    
    it "is false if any attributes are not #==" do
      bob = Person.new(:name => "Bob", :age => 50)
      ted = Person.new(:name => "Ted", :age => 50)
      
      expect(bob).not_to eql(ted)
    end
    
    it "is false if the other object is not of the same class" do
      bob = Person.new(:name => "Bob", :age => 50)
      alien_bob = Struct.new(:name, :age).new("Bob", 50)
      
      expect(bob).not_to eql(alien_bob)
    end
  end
  
  describe "#hash" do
    it "is stable" do
      bob_1 = Person.new(:name => "Bob")
      bob_2 = Person.new(:name => "Bob")
      
      expect(bob_1.hash).to eq(bob_2.hash)
    end
    
    it "varies with the parameters" do
      bob = Person.new(:name => "Bob", :age => 50)
      ted = Person.new(:name => "Ted", :age => 50)
      
      expect(bob.hash).not_to eql(ted.hash)
    end
  end

  describe "::MEMBERS" do
    it "is the list of member variables" do
      expect(Person::MEMBERS).to eq([:name, :age])
    end
  end
  
  describe "#to_hash" do
    it "returns the struct as a hash" do
      person = Person.new(:name => "Bob", :age => 50)
      expect(person.to_hash).to eq({:name => "Bob", :age => 50})
    end
    
    it "is frozen" do
      expect { Person::MEMBERS << :height }.to raise_error(/can't modify frozen/)
    end
  end
  
  describe ".coerce" do
    it "returns the input unmodified if it is already an instance of the struct" do
      person = Person.new
      expect(Person.coerce(person)).to be(person)
    end
    
    it "initializes a new instance if the input is a hash" do
      person = Person.coerce({:name => "Bob"})
      expect(person).to eq(Person.new(:name => "Bob"))
    end
    
    it "raises a TypeError otherwise" do
      expect { Person.coerce("15 lbs of squirrel fur") }.to raise_error(TypeError)
    end
  end
end
