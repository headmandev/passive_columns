# Passive Columns
A gem that extends `Active Record` to retrieve columns from DB on demand.
Works with Rails >= 7 and Ruby >= 2.7

## Usage

```ruby 
  class Page < ApplicationRecord
    include PassiveColumns
    passive_columns :huge_article
  end
```

`ActiveRecord::Relation` now retrieves all the columns except the passive ones by default.
```ruby
  article = Page.where(status: :active).to_a
  # => SELECT "pages"."id", "pages"."status", "pages"."title" FROM "pages" WHERE "pages"."status" = 'active'
```

 If you specify the columns via select it retrieves only the specified columns and nothing more.
```ruby
  page = Page.select(:id, :title).take # => #<Page id: 1, title: "Some title">
  page.to_json # => {"id": 1, "title": "Some title"}

```

But you still has an ability to retrieve the passive column on demand

```ruby
  page.huge_article
  # => SELECT "pages"."huge_article" WHERE "pages"."id" = 1 LIMIT 1
  'Some huge article...'

  page.to_json # => {"id": 1, "title": "Some title", "huge_article": "Some huge article..."}

  # The next time you call the passive column it won't hit the database as it is already loaded.
  page.huge_article # => 'Some huge article...'
```

---


Another way to get columns on demand is to use the `load_column` method.

This method loads a column value, if not already loaded, from the database
regardless of whether the column is added to `passive_columns` or not.

```ruby 
  class User < ActiveRecord::Base
    include PassiveColumns
  end
```
```ruby
user = User.select('id').take!
user.name # missing attribute 'name' for User (ActiveModel::MissingAttributeError)

user.load_column(:name) # => SELECT "name" FROM "users" WHERE "id" = ? LIMIT ?
'John'
user.load_column(:name) # no additional query. It's already loaded
'John'

user.name
'John'
```

By the way, it uses the Rails' `.pick` method to get the value of the column under the hood


## Installation
Add this line to your Gemfile:

```ruby
gem "passive_columns"
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install passive_columns
```

# Motivation

There are situations when you have an `Active Record` model with columns
that you don't want to fetch from a DB every time you manipulate the model.

What options do you have?

```ruby
# You can declare a scope to exclude columns dynamically from the select settings.
scope :skip_retrieving, ->(*v) { select(column_names.map(&:to_sym) - Array.wrap(v)) }
# or you can select only the columns you need
scope :only_main_columns, -> { select(%w[id name description uuid]) }

# When it's really important to skip unnecessary columns, you can use the default scope.
default_scope { :only_main_columns }
```

At first glance, it seems like a good solution.
Until you realize that you cannot manipulate the model without the columns you skipped, as there are validation rules related to them.

```ruby

class Project < ActiveRecord::Base
  scope :only_main_columns, -> { select(%w[id name description uuid]) }

  validates :id, :name, presence: true
  validates :settings, presence: true
end


p = Project.only_required_columns.take
p.update!(name: 'New name') # missing attribute 'settings' for Project (ActiveModel::MissingAttributeError)

```
One way to avoid this is to check for the presence of the attribute before validating it.

```ruby
validates :huge_article, presence: true, if: -> { attributes.key?('huge_article') }
```

Unfortunately, boilerplate code is needed for such a simple task.
You just wanted to exclude some columns and be able to manipulate a model without extra steps.

`passive_columns` tries to solve this problem by allowing you to exclude columns from the selection 
and also allows you to retrieve them on demand when needed.



## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
