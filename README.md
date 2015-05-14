# Anonymizable

Anonymizable adds the ability to anonymize or delete data in your ActiveRecord models. A good use case for this is when you want to remove user accounts but for statistical or data integrity reasons you want to keep the actual records in your database.

## Supported Ruby/Rails Versions

Anonymizable has been tested Rails 3.2.x. Development is underway to support newer Rails versions. In addition, pull requests to support other versions will be received with enthusiasm.

## Installation

This gem has not yet been published to RubyGems. Until such time, add it to your project by adding the following line in the Gemfile:

```ruby
gem 'anonymizable', :git => 'git://github.com/47primes/anonymizable.git'
```
and run `bundle install` from your shell.

## Usage

### Nullification

```ruby
class User < ActiveRecord::Base

  anonymizable do
    attributes :first_name, :last_name
  end

end
```

This adds an instance method ```User#anonymize!``` which in this case just nullifies the ```first_name``` and```last_name``` database columns.

The ```anonymize!``` method is defined as private by default, but you can make it public by passing the ```public``` option:

```ruby
  anonymizable public: true do
    attributes :first_name, :last_name
  end
```

### Anonymization

By passing to ```attributes``` a hash as the last argument, you can anonymize columns using a Proc or instance method.

```ruby
anonymizable public: true do

  attributes  :first_name, :last_name,
              email: Proc.new { |u| "anonymized.user.#{u.id}@foobar.com" }, 
              password: :random_password
end
```

In this example, the ```email``` column will be anonymized by calling the block and passing the ```User``` object. The ```password``` column will be anonymized using the return value of ```User#random_password```, which can be defined as either a public or private instance method. The user object is not passed as an argument in this case, but can be accessed by ```self```.

### Associations

ActiveRecord associations can either be anonymized, destroyed, or deleted. 

```ruby
anonymizable public: true do

  attributes  :first_name, :last_name,
              email: Proc.new { |u| "anonymized.user.#{u.id}@foobar.com" }, 
              password: :random_password

  associations do
    anonymize :posts, :comments
    delete    :avatar, :likes
    destroy   :images
  end

end
```

In the example above, the ```anonymize!``` method will be called on each ```Post``` and ```Comment``` association. As such, anonymization must be defined on both of these classes:

```ruby
class Post < ActiveRecord::Base

  anonymizable :user_id

end
```

```ruby
class Comment < ActiveRecord::Base

  anonymizable :user_id

end
```

In this case, the ```user_id``` column is nullified on any of the user's posts or comments.


**All operations on columns and attributes are performed in a database transaction which will rollback all changes if an error occurs during anonymization.**


### Guards

You can declare a Proc or method to use as a guard against anonymization. If the Proc or method returns ```ruby false``` or ```ruby nil```, anonymization will short circuit.

### Callbacks

You can declare callbacks that run after anonymization is complete.

```ruby
anonymizable public: true do

  attributes  :first_name, :last_name,
              email: Proc.new { |u| "anonymized.user.#{u.id}@foobar.com" }, 
              password: :random_password

  associations do
    anonymize :posts, :comments
    delete    :avatar, :likes
    destroy   :images
  end

  after :email_admin, Proc.new { |original_attrs| log("Attributes changed: #{original_attrs}") }
end
```

Each method or Proc is passed the value of the object's pre-anonymization attributes as a hash. You would define a method on ```User`` that receives the attribute hash:

```ruby
 def email_admin(original_attributes)
    AdminMailer.user_anonymized(original_attributes["email"])
  end
```

It is worth noting that these callbacks are run after the database transaction commits, so an error in a callback does not trigger a database rollback.

### Short Syntax

As intimated in the ```Post``` and ```Comment``` examples above, you can call ```anonymize``` without a block, but rather just with an array of columns to nullify and/or anonymization hash. In this case the ```anonymize!``` instance method will always be private.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
