module Ddb #:nodoc:
  module Userstamp
    # Determines what default columns to use for recording the current stamper.
    # By default this is set to false, so the plug-in will use columns named
    # <tt>creatorr_id</tt>, <tt>updatorr_id</tt>, and <tt>deleter_id</tt>.
    #
    # To turn compatibility mode on, place the following line in your environment.rb
    # file:
    #
    #   Ddb::Userstamp.compatibility_mode = true
    #
    # This will cause the plug-in to use columns named <tt>created_by_id</tt>,
    # <tt>updated_by_id</tt>, and <tt>deleted_by_id</tt>.
    mattr_accessor :compatibility_mode
    @@compatibility_mode = false

    # Extends the stamping functionality of ActiveRecord by automatically recording the model
    # responsible for creating, updating, and deleting the current object. See the Stamper
    # and Userstamp modules for further documentation on how the entire process works.
    module Stampable
      def self.included(base) #:nodoc:
        super

        base.extend(ClassMethods)
        base.class_eval do
          include InstanceMethods

          # Should ActiveRecord record userstamps? Defaults to true.
          class_attribute  :record_userstamp
          self.record_userstamp = true

          # Which class is responsible for stamping? Defaults to :user.
          class_attribute  :stamper_class_name

          # What column should be used for the creatorr stamp?
          # Defaults to :creatorr_id when compatibility mode is off
          # Defaults to :created_by_id when compatibility mode is on
          class_attribute  :created_by_id

          # What column should be used for the updatorr stamp?
          # Defaults to :updatorr_id when compatibility mode is off
          # Defaults to :updated_by_id when compatibility mode is on
          class_attribute  :updated_by_id

          # What column should be used for the deleter stamp?
          # Defaults to :deleter_id when compatibility mode is off
          # Defaults to :deleted_by_id when compatibility mode is on
          class_attribute  :deleted_by_id

          self.stampable
        end
      end

      module ClassMethods
        # This method is automatically called on for all classes that inherit from
        # ActiveRecord, but if you need to customize how the plug-in functions, this is the
        # method to use. Here's an example:
        #
        #   class Post < ActiveRecord::Base
        #     stampable :stamper_class_name => :person,
        #               :creatorr_attribute  => :create_user,
        #               :updatorr_attribute  => :update_user,
        #               :deleter_attribute  => :delete_user
        #   end
        #
        # The method will automatically setup all the associations, and create <tt>before_save</tt>
        # and <tt>before_create</tt> filters for doing the stamping.
        def stampable(options = {})

          class_eval do
            belongs_to :creatorr, :class_name => "User", :foreign_key => "created_by_id"
                                 
            belongs_to :updatorr, :class_name => "User", :foreign_key => "updated_by_id"
                                 
            before_save     :set_updator_attribute
            before_create   :set_creator_attribute
                                 
            if defined?(Caboose::Acts::Paranoid)
              belongs_to :deleter, :class_name => "User", :foreign_key => "deleted_by_id"
              before_destroy  :set_deleter_attribute
            end
          end
        end

        # Temporarily allows you to turn stamping off. For example:
        #
        #   Post.without_stamps do
        #     post = Post.find(params[:id])
        #     post.update_attributes(params[:post])
        #     post.save
        #   end
        def without_stamps
          original_value = self.record_userstamp
          self.record_userstamp = false
          yield
          self.record_userstamp = original_value
        end

        def stamper_class #:nodoc:
          stamper_class_name.to_s.capitalize.constantize rescue nil
        end
      end

      module InstanceMethods #:nodoc:
        private
          def has_stamper?
            !self.class.stamper_class.nil? && !self.class.stamper_class.stamper.nil? rescue false
          end

          def set_creator_attribute
            return unless self.record_userstamp
            if respond_to?(self.created_by_id.to_sym) && has_stamper?
              self.send("#{self.created_by_id}=".to_sym, self.class.stamper_class.stamper)
            end
          end

          def set_updator_attribute
            return unless self.record_userstamp
            if respond_to?(self.updated_by_id.to_sym) && has_stamper?
              self.send("#{self.updated_by_id}=".to_sym, self.class.stamper_class.stamper)
            end
          end

          def set_deleter_attribute
            return unless self.record_userstamp
            if respond_to?(self.deleted_by_id.to_sym) && has_stamper?
              self.send("#{self.deleted_by_id}=".to_sym, self.class.stamper_class.stamper)
              save
            end
          end
        #end private
      end
    end
  end
end

ActiveRecord::Base.send(:include, Ddb::Userstamp::Stampable) if defined?(ActiveRecord)