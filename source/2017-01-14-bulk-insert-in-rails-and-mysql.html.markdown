---
title: Better Bulk Inserts in Rails
date: 2017-01-14 01:30 EST
tags:
---

One of the limitations of Rails is that it doesn't do a true bulk insert. For example, let's say you have a `MenuItem`
model and pass it an array of objects to create like this:

```ruby
items_to_create = [
  {
    name: 'Sandwich',
    description: 'Chips included',
    price: 10.00,
  },
  {
    name: 'Soup',
    description: 'Cream of mushroom',
    price: 3.00    
  },
  {
    name: 'Salmon',
    description: 'Pan seared',
    price: 17.00
  },
]

MenuItem.create!(items_to_create)
```

When you call `MenuItem.create!`, ActiveRecord will actually perform 3 separate INSERT queries on the database rather 
than one bulk insert query. It will look something like this:

```sql
INSERT INTO models (...) VALUES (...);
INSERT INTO models (...) VALUES (...);
INSERT INTO models (...) VALUES (...);
```

The problem with this approach is that it is inefficient - DB engines are much faster at peforming INSERT when fed the 
data all at once. I'm working on a project that requires a huge manipulation of data and thus many DB queries. To make 
it run faster I've tried to minimize the number of individual queries. One way that I was able to speed this up is to 
build my own native bulk insert routine for ActiveRecord that works with MySQL. Here is the code:

```ruby
# app/models/concerns/has_bulk_insert.rb

module HasBulkInsert
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    BI_IGNORE_COLUMNS=%w(id)

    def bulk_insert(values_array)
      return if values_array.empty?
      ActiveRecord::Base.connection.execute bi_sql(values_array)
    end

    protected
    def bi_column_definitions
      self
        .columns_hash
        .map {|col,props| BI_IGNORE_COLUMNS.include?(col) ? nil : {col=>props.type} }
        .compact
        .reduce({}, :merge)
    end

    def bi_escaped_column_names
      bi_column_definitions.reduce([]) { |m,(k,v)| m << "`#{k}`" }.join(',')
    end

    def bi_sql(values_array)
      <<SQL
INSERT INTO #{self.table_name} (#{bi_escaped_column_names}) VALUES
#{bi_convert_values_array(values_array)};
SQL
    end

    def bi_convert_values_array(values_array)
      values_array.map do |values_hash|
        line_values = bi_column_definitions.reduce([]) do |line, (col,definition)|
          vh = values_hash.stringify_keys

          next line << 'NULL' if vh[col].nil? && !is_timestamp_column?(col)

          case definition
            when :string, :text
              if is_enum_column?(col)
                line << "'#{enum_value(col, vh[col])}'"
              else
                line << "'#{vh[col].gsub("'", "''")}'"
              end
            when :date
              line << "'#{vh[col].strftime('%Y-%m-%d')}'"
            when :datetime
              if is_timestamp_column?(col)
                line << "'#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}'"
              else
                line << "'#{vh[col].strftime('%Y-%m-%d')}'"
              end
            when :integer
              if vh[col].is_a? Integer
                line << vh[col].to_s
              elsif vh[col].is_a?(String) && is_enum_column?(col)
                line << "'#{enum_value(col, vh[col])}'"
              else
                raise "Unable to interpret data for column #{col}\n#{vh}"
              end
            when :decimal, :boolean
              line << vh[col].to_s
            else
              raise "Unknown data column type: #{definition}"
          end
        end
        .join(',')

        "(#{line_values})"
      end
      .join(",\n")
    end

    def enum_value(column_name, enumeration_value)
      self.send(column_name.pluralize)[enumeration_value]
    end

    def is_enum_column?(column_name)
      self.defined_enums.include?(column_name)
    end

    def is_timestamp_column?(column_name)
      %w(created_at updated_at).include?(column_name)
    end
  end
end
```

To use this, all you have to do is include the module in your model like this:

```ruby
class MenuItem < ApplicationRecord
  include HasBulkInsert
end
```

Now you can call the method:

```ruby
MenuItem.bulk_insert(items_to_create)  
```
The SQL query used by ActiveRecord will be consolidated to look more like this:

```sql
INSERT INTO models (...) VALUES
  (...),
  (...),
  (...),
  (...),
  ...
```

One limitation of my code module at this point is that it does not support serialized fields, but it is excellent for
basic tables and speeds things up tremendously - by about 50% in my local bench tests!

### Related Links

[StackOverflow: Which is faster: single inserts or one multiple row insert?](http://stackoverflow.com/questions/1793169/which-is-faster-multiple-single-inserts-or-one-multiple-row-insert) 