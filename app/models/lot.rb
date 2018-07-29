class Lot < ActiveRecord::Base
  belongs_to :book, :touch => true
  belongs_to :user

  after_save :update_book_cache
  after_destroy :dekrement, :if => :is_active

  attr_accessor :book_title, :book_authors, :ozon_coverid, :book_genre, :bookid, :ozonid,
                :ozon_flag

  attr_accessible :price, :comment, :can_deliver, :can_postmail, :cover,
                  :skypename, :phone, :cityid, :book_authors, :book_title, :book_genre,
                  :ozonid, :ozon_coverid, :bookid, :ozon_flag

  validates :book_authors,
            :presence => true,
            :allow_blank => false,
            :unless => :book_id

  validates :book_title,
            :presence => true,
            :allow_blank => false,
            :unless => :book_id

  validates :book_genre, :presence => true,
            :allow_blank => false,
            :unless => :book_id

  validates :comment,
            :length => {:maximum => 255},
            :allow_blank => true

  validates :skypename,
            :length => {:in => 4..30},
            :format => {:with => /^[-_.a-zA-Z0-9]{4,30}$/},
            :allow_blank => true

  validates :phone,
            :format => {:with => /^[\(\)0-9\- \+\.]{10,17}$/,
                        :message => I18n.t("errors.messages.phone_format")},
            :length => {:minimum => 10,
                        :maximum => 15,
                        :tokenizer => lambda { |str| str.scan(/\d/) },
                        :message => I18n.t("errors.messages.phone_format")
            },
            :allow_blank => true

  validates :cityid,
            :numericality => {:greater_than_or_equal_to => -1},
            :allow_blank => false

  validates :price,
            :numericality => {:greater_than_or_equal_to => 0,
                              :only_integer => true
            },
            :allow_nil => false # default is Zero

  validates :book_id,
            :presence => true,
            :allow_nil => false

  validates :user_id,
            :presence => true,
            :allow_nil => false

  has_attached_file :cover,
                    :whiny_thumbnails => true,
                    :path => ":rails_root/public/system/covers/:class-:user_partition/:user_id/:id_partition:hash_:style.:extension",
                    :url => "/system/covers/:class-:user_partition/:user_id/:id_partition:hash_:style.:extension",
                    :default_url => '/covers/missing_:style.png',
                    :hash_secret => ENV['LOT_PAPERCLIP_SECRET'],
                    :hash_data => ":class/:attachment/:id",
                    :styles =>
                        {:original => ["560x800>", :jpg],
                         :x300 => ["200x300", :jpg],
                         :x200 => ["200x200", :jpg],
                         :x120 => ["120x120", :jpg]},

                    :convert_options => {
                        :original => "-quality 64",
                        :x300 => "-gravity center -extent 200x300 -quality 67",
                        :x200 => "-gravity center -extent 200x200 -quality 70",
                        :x120 => "-gravity center -extent 120x120 -quality 72"}

  validates_attachment_size :cover, :less_than => 4.megabytes, :message => I18n.t('paperclip.errors.upload_size')

  validates_attachment_content_type :cover,
                                    :content_type => %w(image/jpeg image/pjpeg image/x-png image/png image/tif image/tiff image/bmp image/gif),
                                    :message => I18n.t('paperclip.errors.img_type')

  validate :file_dimensions, :unless => "errors.any? || !cover.present?", :on => :create

  before_post_process :check_file_size

  scope :fresh_first, :order => 'lots.updated_at DESC'
  scope :old_first, :order => 'lots.updated_at ASC'

  scope :active, :conditions => {:is_active => true}
  scope :inactive, :conditions => {:is_active => false}
  scope :dead_user, joins('left outer join users on lots.user_id=users.id').where('users.id is null')

  #noinspection RubyArgCount
  def similar_lots
    lots = self.book.lots.fresh_first.active.in_city(self.cityid).where('id != ?', self.id).where('user_id != ?', self.user_id).limit(20)
    result = {}
    lots.each do |item|
      result[item.user_id] ||= item
    end
    result.values
  end


  # includes <Any city> lots
  def self.in_city(cityid)
    where(:cityid => [cityid, -1]) # -1 == any city
  end

  # Complex Lot obtainer
  #
  # Valid options are:
  # 1. These ones except one another (higher - the more priority)
  #   * <tt>:bookid</tt> – id of a book to look lots for
  #   * <tt>:genre</tt> – genre of a books to look lots for
  #   * <tt>:authorid</tt>
  # 2. These ones can intersect another (AND condition)
  #   * <tt>:userid</tt>
  #   * <tt>:city</tt>
  #   * <tt>:is_active</tt> – default true
  # 3. Order & paging:
  #   * <tt>:order_by</tt> – can be *:date*, *:author* or *:price*, default *:date*
  #   * <tt>:order_to</tt> – *:desc* (default) or *:asc*
  #   * <tt>:limit</tt> - default 8
  #   * <tt>:page</tt> – default 1
  def self.custom(options = {})
    #cleanup vars
    options[:city] = nil if options[:city].to_i == -1
    options[:limit] ||= 8
    options[:page] ||= 1

    is_active = param_bool(options[:is_active])

    options[:order_to] = case options[:order_to].to_s.casecmp('asc')
                           when 0 then
                             'ASC'
                           else
                             'DESC'
                         end

    options[:order_by] = case options[:order_by].to_s
                           when 'date' then
                             'lots.updated_at '
                           when 'author' then
                             'authors.last '
                           when 'price' then
                             'lots.price '
                           else
                             'lots.updated_at '
                         end

    conditstr = ""
    conditstr += "books.id = :bookid AND " if options[:bookid].present?
    conditstr += "books.genre = :bookgenre AND " if options[:genre].present? && options[:bookid].blank?
    conditstr += "authors.id = :authorid AND " if options[:authorid].present? && options[:bookid].blank?
    conditstr += "users.id = :userid AND " if options[:userid].present? && options[:bookid].blank?
    conditstr += "lots.cityid IN (:cityid, -1) AND " if options[:city].present?
    conditstr += "lots.is_active = :lotactive"

    # heavy joins must be cached soon!
    Lot.includes([{:book => :authors}, :user]).
        where(conditstr, {:bookid => options[:bookid],
                          :bookgenre => options[:genre],
                          :authorid => options[:authorid],
                          :userid => options[:userid],
                          :cityid => options[:city],
                          :lotactive => is_active}).
        order(options[:order_by] + options[:order_to]).
        paginate(:page => options[:page], :per_page => options[:limit].to_i)
  end

  def phone
    phon = read_attribute(:phone)

    if phon.blank?
      # not using :joins so don't set'
      #return u_phone if respond_to?(:u_phone) # u_phone - virtual attribute cached from DB User object
      (user.present?) ? user.phone : phon
    else
      phon
    end
  end

  def cityid
    city = read_attribute(:cityid)
    (city.blank? && user.present?) ? user.cityid : city
  end

  def skypename
    skyp = read_attribute(:skypename)

    if skyp.blank?
      # not using :joins so don't set virtual attrbutes yet
      #return u_skype if respond_to?(:u_skype) # u_skype - virtual attribute cached from DB User object
      (user.present?) ? user.skypename : skyp
    else
      skyp
    end
  end

  def get_cover(style)
    if cover.present? # relying on paperclip :default_url option for missing attachment
      cover.url(style)
    else
      book.get_cover(style)
    end
  end

  def cityname
    Globals::CITIES[cityid]
  end

  private

  def file_dimensions
    #system("open " + cover.path(:original))
    #puts cover.original_filename
    #puts cover.uploaded_file.path
    dimensions = Paperclip::Geometry.from_file(cover.queued_for_write[:original])
    if dimensions.width < 200 || dimensions.height < 200
      errors.add(:cover, I18n.t('paperclip.errors.img_dimension'))
    end
  end


  def check_file_size
    valid?
    errors[:cover_file_size].blank?
  end

  def update_book_cache
    if self.is_active_changed? || self.book_id_changed?
      if self.is_active
        inkrement
      elsif !self.book_id_changed?
        dekrement
      end
    else
      update_min_price
    end

    book.save unless book.nil?
  end

  def inkrement
    update_min_price
    # XXX: self.book must be reloaded before updating lots_count
    book.increment!(:lots_count, 1) unless book.nil?
  end

  def dekrement
    update_min_price
    # XXX: self.book must be reloaded before updating lots_count
    book.increment!(:lots_count, -1) unless book.nil?
  end

  def update_min_price
    #set new book min_price
    unless book.nil?
      book.reload
      book.min_price = book.lots.active.minimum(:price)
      book.save
    end
  end
end
