module Ddb
  module Userstamp
    module MigrationHelper
      def self.included(base) # :nodoc:
        base.send(:include, InstanceMethods)
      end

      module InstanceMethods
        def userstamps(include_deleted_by_id = false)
          column(Ddb::Userstamp.compatibility_mode ? :created_by_id : :creatorr_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :updated_by_id : :updatorr_id, :integer)
          column(Ddb::Userstamp.compatibility_mode ? :deleted_by_id : :deleter_id, :integer) if include_deleted_by_id
        end
      end
    end
  end
end

ActiveRecord::ConnectionAdapters::Table.send(:include, Ddb::Userstamp::MigrationHelper)
