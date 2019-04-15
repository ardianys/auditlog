# Simple Audit Trail
# ** rails_3 branch and 0.0.x gem versions is Rails 3x, for the rails 4 compatible gem, use the 1.x.x gem versions and the master branch**
## Synopsis

Use to create an audit trail of field changes in a model, storing what was
changed and who changed it.

**Setup**

1. Add to your Gemfile: ``` gem 'auditlog ```
1. Install the gem ``` bundle install ```
1. Run the rake task to copy the migrations: ``` rake auditlog_engine:install:migrations ```
1. Migrate: ``` rake db:migrate ```


1. You must have a current_user method in your app. If not, you'll need to override
``` auditlog_who_id ``` to provide a user id

**Model**

```
class Thing < ActiveRecord::Base
  audit [:some_field, :some_other_field]
end
```


**Usage**

Thing instances now have an attribute, ` audited_user_id `.

You must set this on the object before you save it with changes to the audited
fields, or the audit attempt will fail, and raise an exception.

Assuming you have the above model, and that your controller has access to the
usual `current_user` method, you could do something like:

```ruby
  t = Thing.find(1)
  t.some_field
  #=> "foo"
  t.audited_user_id = current_user.id
  t.some_field = "bar"
  t.save
```

which would generate a record in ` t.simple_audits `

* If you don't wish to track users, but just track changes,
add ` :require_audited_user_id => false ` to your `audit` call.
