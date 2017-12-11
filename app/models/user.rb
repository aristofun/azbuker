# coding: utf-8

class User < ActiveRecord::Base
  has_many :lots, :dependent => :delete_all

  # Include default devise modules. Others available are:
  # :encryptable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :token_authenticatable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable

  # generate unique user name initially
  before_validation :create_nickname, :on => :create

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :agreement, :nickname, :skypename, :phone, :cityid

  auto_strip_attributes :nickname, :skypename, :phone, :cityid, :squish => true

  validates_acceptance_of :agreement, :allow_nil => false, :on => :create

  validates :cityid,
            :numericality => {:greater_than_or_equal_to => -1},
            :allow_nil => false

  validates :nickname,
            :length => {:in => 3..20},
            :uniqueness => true

  validates :skypename,
            :length => {:in => 4..30},
            :format => {:with => /^[-_.a-zA-Z0-9]{4,30}$/},
            :allow_blank => true

  validates :phone,
            :format => {:with => /^[\(\)0-9\- \+\.]{10,17}$/,
                        :message => I18n.t("activerecord.errors.messages.phone_format")},
            :length => {:minimum => 10,
                        :maximum => 15,
                        :tokenizer => lambda { |str| str.scan(/\d/) },
                        :message => I18n.t("activerecord.errors.messages.phone_format")
            },
            :allow_blank => true

  after_initialize { self.cityid ||= -1 }
  scope :unconfirmed, where(:confirmed_at => nil)
  scope :admins, where(:admin => true)

  def confirm!
    super
    UserMailer.welcome_alert(self).deliver
  end

  private

  def create_nickname
    if nickname.blank?
      self.nickname = nick_generator
    end
  end

  def nick_generator
    i = 0
    mailpart = self.email.split("@")[0][0, 17] if self.email.present?
    mailpart ||= "#{I18n.l(Time.now, :format => "%b")}#{SecureRandom.random_number(99)}"
    mailpart << "_" if mailpart.length < 3
    while mailpart.length < 3 || User.find_by_nickname(mailpart).present?
      mailpart = mailpart + " " + i.to_s
      i += 1
    end
    mailpart
  end
end
