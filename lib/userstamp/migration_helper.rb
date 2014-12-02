module Ddb
  module Userstamp
    module MigrationHelper
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def userstamps(include_deleted_by = false)
          column(Ddb::Userstamp.compatibility_mode ? :created_by : :maker_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :updated_by : :modifier_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :deleted_by : :deleter_id, :integer) if include_deleted_by
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send(:include, Ddb::Userstamp::MigrationHelper)
