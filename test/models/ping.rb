class Ping < ActiveRecord::Base
  stampable :stamper_class_name => :person,
            :maker_attribute  => :maker_name,
            :modifier_attribute  => :modifier_name,
            :deleter_attribute  => :deleter_name
  belongs_to :post
end