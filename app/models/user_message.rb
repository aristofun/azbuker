# coding: utf-8

class UserMessage
  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  # Setup accessible (or protected) attributes for your model
  attr_accessor :email, :text, :type, :lotid, :userid
  attr_accessible :email, :text, :type, :lotid, :userid

  validates_numericality_of :userid, :lotid

  validates :email,
            :presence => true,
            :format => {:with => /\A[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]+\z/},
            :allow_blank => false

  validates :text,
            :length => {:in => 7..300},
            :allow_blank => false,
            :unless => :type

  validates :type,
            :numericality => true,
            :allow_blank => true

  def initialize(attributes = {})
    sanitize_for_mass_assignment(attributes).each do |k, v|
      public_send("#{k}=", v.strip)
    end if attributes
  end

  def persisted?
    false
  end
end
