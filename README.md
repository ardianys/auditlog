# Audit LOG
## Synopsis

Use to create an audit trail of field changes in a model, storing what was
changed and who changed it in log file instead in DB

**Setup**

1. Add to your Gemfile: ``` gem 'auditlog', github: 'ardianys/auditlog' ```
1. Install the gem ``` bundle install ```

**Model**

```
class Thing < ActiveRecord::Base
  audit [:some_field, :some_other_field]
end
```


**Usage**

Thats it

**LOG**

$ tailf log/audit.log

You can stream your log file to ELK stack using Logbyte