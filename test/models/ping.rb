class Ping < ActiveRecord::Base
  stampable :stamper_class_name => :person,
            :creatorr_attribute  => :creatorr_name,
            :updatorr_attribute  => :updatorr_name,
            :deleter_attribute  => :deleter_name
  belongs_to :post
end