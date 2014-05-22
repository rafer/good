# Good 

2 little things that make writing good Ruby programs a little easier.

1. `Good::Value` is a class generator for simple, pleasant, immutable [Value objects](http://en.wikipedia.org/wiki/Value_object).

2. `Good::Record` is a class generator for simple, pleasant, mutable [Record objects](http://en.wikipedia.org/wiki/Record_(computer_science) "Record Objects"). They're a lot like `Struct`.

## Usage

Both are used the same way, like this:

```ruby
class Person < Good::Value.new(:name, :age)
end
```

or like this if you prefer:

```ruby
Person = Good::Value.new(:name, :age)
```

Now, we can create a `Person`:

```ruby
person = Person.new(:name => "Mrs. Betty Slocombe", :age => 46)
```

and ask it about itself:

```ruby
person.name # => "Mrs. Betty Slocombe"
person.age  # => 46 
```

`Good::Value` objects are immutable:

```ruby
person.name = "Captain Stephen Peacock" #=> NoMethodError: undefined method `name=' for ...
```

But don't worry, you can still get what you want:

```ruby
person = person.merge(:name => "Captain Stephen Peacock")
person.name # => "Captain Stephen Peacock"
```

Most of the time immutable is good. If you don't want that though, try
`Good::Record`:

```ruby
class Person < Good::Record.new(:name, :age)
end
```

Now we can mutate the object:

```ruby
person = Person.new(:name => "Mrs. Betty Slocombe", :age => 46)
person.age = 30
person.age # => 30
```

Except for mutability `Good::Value` and `Good::Record` have the same interface.

Don't forget, `Good::Value` and `Good::Record` create regular Ruby classes so
they get to have methods just like everybody else:

```ruby
class Person < Good::Value.new(:name, :age)
  def introduction 
    "My name is #{name} and I'm #{age} years old"
  end
end
```

or, via block:

```ruby
Person = Good::Value.new(:name, :age) do
  def introduction 
    "My name is #{name} and I'm #{age} years old"
  end
end
```

Also, classes created with `Good::Value` and `Good::Record` have reasonable
implementations of `#==`, `#eql?` and `#hash`.

## Bonus Features

You can ask `Good::Value` and `Good::Record` instances about their structure
and contents:

```ruby
person = Person.new(:name => "Miss Brahms", :age => 30)

Person::MEMBERS   # => [:name, :age]
person.members    # => [:name, :age]
person.values     # => ["Miss Brahms", 30]
person.attributes # => {:name => "Miss Mrahms", :age => 30}
```

You can call `Person.coerce` to coerce input to a `Person` in the following
ways:

```ruby
# from a Hash (creates a new Person)
Person.coerce(:name => "Mr. Ernest Grainge") # => #<Person:0x007fbe9121d048 @name="Mr. Ernest Grainge"> 

# from a Person (returns the input unmodified)
person = Person.new(:name => "Mr. Cuthbert Rumbold") 
Person.coerce(person) # => #<Person:0x007fbe920270f8 @name="Mr. Cuthbert Rumbold">

# from something wrong  
Person.coerce("WRONG") # => TypeError: Unable to coerce String into Person
```

`.coerce` is particularly useful at code boundaries. It allows clients to pass
options as a hash if they want to, while allowing you to use the type you
expected confidently (because blatantly incorrect values raise a `TypeError`). 

## Motivation

Why does the world need this?

### `Good` vs Regular Ruby Objects 

Creating value classes is a good idea. Properly used, they make testing easier,
help with separation of concerns and make interfaces more apparent. In Ruby, we
like to do stuff with as little ceremony as possible. So what's wrong with a
regular class:

```ruby
class Person
  attr_accessor :age, :name
end 
```

Nothing, really. The only problem is that, in order to get an object that's
easy to work with, you'll probably want to implement `#initialize`, `#==`,
`#eql?` and `#hash`. This isn't really so bad, but if you want to quickly create
a number of these classes, the boilerplate code gets heavy pretty quickly. Plus
you'll probably do it wrong the first time (I certainly did).

It's worth noting that `Good` in no way seeks to become the foundation of your
domain model. The second a class outgrows its `Good::Value` or `Good::Record`
roots, by all means you should remove `Good` from the picture and rely on pure
Ruby classes instead. `Good` helps you get started quickly by making a
particular pattern easy, but when your classes get more mature, it's time for
`Good` to go.

### `Good` vs `Hash`

In general, passing hashes around in your application is a bad idea, unless the
data they contain is truly unstructured. Since you can't add methods to hashes
(unless you subclass them, which is perhaps its own variety of bad idea), a
little bit of the logic to deal with these "structured" hashes gets spread
around a lot of places.

With a hash it can also be hard to figure out exactly what it is expected to
contain. In many cases the passing of a hash with specific expectations about
its contents is an indication that you're missing a class.  Hopefully, prudent
application of `Good::Value` and `Good::Record` will allow you extract that
class more quickly, with minimal extra work.

However, this is not to say that you should not use a hash at the boundary
between client and library, or between various modules in your system. For
example, say we've got an `Authenticator` class that takes a user's credentials:

```ruby
class Authenticator
  def initialize(credentials)
    username = credentials[:username]
    password = credentials[:password]
  end

  def authentic?
    # ...
  end
end
```

This is a perfectly reasonable interface for a client to use:

```ruby
authenticator = Authenticator.new({
  :username => "m.grace@gracebrothers.com",
  :password => "rUbngS3rvd"
})

login if authenticator.authentic?
```

The following implementation maintains the same interface for the client and
adds very little code: 

```ruby
class Authenticator
  Credentials = Good::Value.new(:username, :password)

  def initialize(credentials)
    @credentials = Credentials.coerce(credentials)
  end

  def authentic?
    # ...
  end
end
```

Say now that the Authenticator needs to pass the user's credentials to
another component (to log the attempt, for example), we are now in the enviable
position of having an object, with a well defined interface to pass around -
not a hash with implicit assumptions about its contents. Further, because of
the `.coerce` method we can now accept a hash at the boundary or a fully formed
`Credentials` object, it makes no difference to the `Authenticator`.

This evolution seems fairly common. To solve an immediate problem, a new
`Good::Value` class is created inside the namespace of an existing class, which
is at first desirable because it does not inflict this abstraction externally.
Then, as the class begins to interact with other components in the system,
this previously internal class can be made external and evolved into it's own
fully fledged domain object (perhaps shedding `Good` in the process). When you
start with a hash, it can be harder to spot the "missing" class.

## Installation

Add this line to your application's Gemfile:

    gem 'good'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install good

## Tests 

    bundle && bundle exec rake

## Credits

* Borrowed heavily from https://github.com/tcrayford/Values

