require "bundler/setup"

shared_examples :good do
  before do
    class Person < described_class.new(:name, :age)
    end
  end

  after do
    Object.send(:remove_const, :Person)
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
      alien_bob = described_class.new(:name, :age).new(:name => "Bob", :age => 50)
      
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
    
    it "is frozen" do
      expect { Person::MEMBERS << :height }.to raise_error(/can't modify frozen/)
    end
  end
 
  describe "#members" do
    it "is the list of member variables" do
      person = Person.new
      expect(person.members).to eq([:name, :age])
    end

    it "is modifiable without affecting the original members" do
      person = Person.new
      person.members << :height
      expect(person.members).to eq([:name, :age])
    end
  end

  describe "#values" do
    it "is the list of values (in the same order as the #members)" do
      person = Person.new(:age => 50, :name => "BOB")
      expect(person.values).to eq(["BOB", 50])
    end
  end

  describe "#attributes" do
    it "is a hash of the attributes (with symbol keys)" do
      person = Person.new(:name => "Bob", :age => 50)
      expect(person.attributes).to eq(:name => "Bob", :age => 50)
    end
  end

  describe "#merge" do
    it "returns an object with the given properties modified" do
      young = Person.new(:name => "Bob", :age => 50)
      old = young.merge(:age => 51)

      expect(old.name).to eq("Bob")
      expect(old.age).to eq(51)
    end

    it "does not mutate the old object" do
      person = Person.new(:name => "Bob", :age => 50)
      person.merge(:age => 51)

      expect(person.age).to eq(50)
    end

    it "accepts 0 arguments" do
      person = Person.new
      expect(person.merge).not_to be(person)
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
  
  describe "block construction" do
    let(:car_klass) do
      described_class.new(:wheels) do
        def drive
          "Driving with all #{wheels} wheels!"
        end
      end
    end
    
    it "allows definition of methods" do
      car = car_klass.new(:wheels => 4)
      expect(car.drive).to eq("Driving with all 4 wheels!")
    end
  end
end

describe Good::Struct do
  include_examples(:good)

  it "is mutable" do
    person = Person.new
    expect { person.name = "Bob" }.to change { person.name }.to("Bob")
  end
end

describe Good::Value do
  include_examples(:good)

  it "is immutable" do
    person = Person.new
    expect { person.name = "Bob" }.to raise_error(NoMethodError) 
  end
end

