module Ddb #:nodoc:
  module Userstamp
    # Determines what default columns to use for recording the current stamper.
    # By default this is set to false, so the plug-in will use columns named
    # <tt>maker_id</tt>, <tt>modifier_id</tt>, and <tt>deleter_id</tt>.
    #
    # To turn compatibility mode on, place the following line in your environment.rb
    # file:
    #
    #   Ddb::Userstamp.compatibility_mode = true
    #
    # This will cause the plug-in to use columns named <tt>created_by</tt>,
    # <tt>updated_by</tt>, and <tt>deleted_by</tt>.
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

          # What column should be used for the maker stamp?
          # Defaults to :maker_id when compatibility mode is off
          # Defaults to :created_by when compatibility mode is on
          class_attribute  :maker_attribute

          # What column should be used for the modifier stamp?
          # Defaults to :modifier_id when compatibility mode is off
          # Defaults to :updated_by when compatibility mode is on
          class_attribute  :modifier_attribute

          # What column should be used for the deleter stamp?
          # Defaults to :deleter_id when compatibility mode is off
          # Defaults to :deleted_by when compatibility mode is on
          class_attribute  :deleter_attribute

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
        #               :maker_attribute  => :create_user,
        #               :modifier_attribute  => :update_user,
        #               :deleter_attribute  => :delete_user
        #   end
        #
        # The method will automatically setup all the associations, and create <tt>before_save</tt>
        # and <tt>before_create</tt> filters for doing the stamping.
        def stampable(options = {})
          defaults  = {
                        :stamper_class_name => :user,
                        :maker_attribute  => Ddb::Userstamp.compatibility_mode ? :created_by : :maker_id,
                        :modifier_attribute  => Ddb::Userstamp.compatibility_mode ? :updated_by : :modifier_id,
                        :deleter_attribute  => Ddb::Userstamp.compatibility_mode ? :deleted_by : :deleter_id
                      }.merge(options)

          self.stamper_class_name = defaults[:stamper_class_name].to_sym
          self.maker_attribute  = defaults[:maker_attribute].to_sym
          self.modifier_attribute  = defaults[:modifier_attribute].to_sym
          self.deleter_attribute  = defaults[:deleter_attribute].to_sym

          class_eval do
            belongs_to :maker, :class_name => self.stamper_class_name.to_s.singularize.camelize,
                                 :foreign_key => self.maker_attribute
                                 
            belongs_to :modifier, :class_name => self.stamper_class_name.to_s.singularize.camelize,
                                 :foreign_key => self.modifier_attribute
                                 
            before_save     :set_modifier_attribute
            before_create   :set_maker_attribute
                                 
            if defined?(Caboose::Acts::Paranoid)
              belongs_to :deleter, :class_name => self.stamper_class_name.to_s.singularize.camelize,
                                   :foreign_key => self.deleter_attribute
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

          def set_maker_attribute
            return unless self.record_userstamp
            if respond_to?(self.maker_attribute.to_sym) && has_stamper?
              self.send("#{self.maker_attribute}=".to_sym, self.class.stamper_class.stamper)
            end
          end

          def set_modifier_attribute
            return unless self.record_userstamp
            if respond_to?(self.modifier_attribute.to_sym) && has_stamper?
              self.send("#{self.modifier_attribute}=".to_sym, self.class.stamper_class.stamper)
            end
          end

          def set_deleter_attribute
            return unless self.record_userstamp
            if respond_to?(self.deleter_attribute.to_sym) && has_stamper?
              self.send("#{self.deleter_attribute}=".to_sym, self.class.stamper_class.stamper)
              save
            end
          end
        #end private
      end
    end
  end
end

ActiveRecord::Base.send(:include, Ddb::Userstamp::Stampable) if defined?(ActiveRecord)