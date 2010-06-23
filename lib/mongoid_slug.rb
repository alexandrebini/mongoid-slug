# Generates a URL slug/permalink based on a field in a Mongoid model.
module Mongoid::Slug
  
  def self.included(base)
    class << base
      attr_accessor :slugged_field
      attr_accessor :slugged_source
    end
    base.extend ClassMethods
  end

  module ClassMethods #:nodoc:
    
    # Set a field as source of slug
    def slug(field, options={})
      self.slugged_field = options[:as] || :slug
      self.slugged_source = field
      field self.slugged_field, :type => String
      before_save :slugify
    end

    def find_by_slug(slug)
      where(self.slugged_field => slug).first
    end
  end

  def to_param
    read_attribute(slugged_field)
  end

  private

  def slugify
    self.send "#{slugged_field.to_s}=", find_unique_slug if new_record? || self.send((slugged_source.to_s + '_changed?').to_sym)
  end

  def find_unique_slug(suffix='')
    slug = ("#{read_attribute(slugged_source)} #{suffix}").parameterize

    if collection.find(slugged_source => slug).count == 0
      slug
    else
      new_suffix = suffix.blank? ? '1' : "#{suffix.to_i + 1}"
      find_unique_slug(new_suffix)
    end
  end
  
  def slugged_field
    self.class.slugged_field
  end
  def slugged_source
    self.class.slugged_source
  end
end
