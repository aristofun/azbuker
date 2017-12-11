# coding: utf-8
class Author < ActiveRecord::Base
  has_and_belongs_to_many :books

  auto_strip_attributes :first, :middle, :last, :squish => true
  attr_accessible :first, :middle, :last

  before_validation :create_names

  validates :first, :middle,
            :allow_blank => true,
            :format => {:with => /^[ \-\(\)"'\p{Alnum}]+$/}

  validates :last,
            :presence => true,
            :allow_blank => false,
            :format => {:with => /^[\-\(\)"'\s\p{Alnum}]+$/}

  validates :short,
            :presence => true,
            :allow_blank => false

  validates :full,
            :presence => true,
            :allow_blank => false,
            :uniqueness => true

  scope :unbooked, joins('left outer join authors_books on authors.id=authors_books.author_id').
      where('authors_books.book_id is null')

  def f
    first[0] unless first.nil?
  end

  def m
    middle[0] unless middle.nil?
  end


  def self.from_string(name_string)
    return nil if name_string.blank?
    fml = extract_first_middle_last(name_string)
    first, middle, last = fml

    if fml[0].to_s.length > 1 && fml[2].to_s.length == 1 # fml= Pushkin A. S.
      first = fml[1] || fml[2] # first = A. || S.
      middle = fml[2] if fml[1].present? # middle = S.
      last = fml[0]
    end

    test_author = Author.new(:last => last, :first => first, :middle => middle)
    test_author.create_names
    candidate = nil
    #p "test author: " + test_author.last.mb_chars.downcase.to_s
    possible_authors = Array.wrap(
        Author.where(:last => test_author.last).limit(20).order('created_at ASC')
    )
    #p "found smthng: " + possible_authors.map(&:full).to_s
    if possible_authors.present?
      possible_authors.each do |author|
        if author.same_as? test_author
          #p "same author"
          return author
        end
        if author.almost_same_as?(test_author) && candidate.nil?
          # совпали инициалы и подходят first/middle имена
          #p "almost_same"
          candidate = author
        end
        if author.looks_like?(test_author) && candidate.nil?
          #p "looks_like"
          # совпала фамилия и подходящие инициалы
          candidate = author
        end
      end
    end

    #p "before get_updated: candid " + candidate.try(:full).to_s + ", test: " + test_author.full
    auth = get_updated(candidate, test_author)
    auth.save
    #p "auth: " + auth.inspect
    auth
  end

  def self.get_updated(candidate, test_author)
    return test_author if candidate.nil?

    if (candidate.first == test_author.f || candidate.first.blank?)
      candidate.first = test_author.first
    end

    if (candidate.middle == test_author.m || candidate.middle.blank?)
      candidate.middle = test_author.middle
    end
    candidate
  end

  def looks_like?(test_author)
    (last.mb_chars.downcase == test_author.last.mb_chars.downcase) &&
        # совпадает имя, отчество или инициалы
        (
        ((first == test_author.first || f == test_author.first || first == test_author.f || test_author.first.blank? || first.blank?) &&
            (m == test_author.middle || middle == test_author.middle || middle == test_author.m || middle.blank? || test_author.middle.blank?))
        )
  end

  def almost_same_as?(test_author)
    (short == test_author.short) && looks_like?(test_author)
  end

  def same_as?(test_author)
    return false if test_author.nil?
    full.mb_chars.downcase == test_author.full.mb_chars.downcase
  end

  def create_names
    self.first = first.mb_chars.titleize.to_s unless first.blank?
    self.middle = middle.mb_chars.titleize.to_s unless middle.blank?

    if last.present?
      #self.last = last.mb_chars.gsub(/(?<=['\-"\(\s])?([\p{Alnum}]+)/u) {|match| match.mb_chars.capitalize.to_s }
      self.last = last.mb_chars.gsub(/[\p{Alnum}]+/u) { |match| match.mb_chars.capitalize.to_s }
    end
    #last[0].mb_chars.upcase.to_s + last[1..-1] unless last.blank?

    self.full = "#{first} #{middle} #{last}".squish
    self.short = "#{first.blank? ? "" : first[0].mb_chars.upcase.to_s + "."}
    #{middle.blank? ? "" : middle[0].mb_chars.upcase.to_s + "."}
    #{last}".squish
  end

  def self.extract_first_middle_last(name_string)
    name_string.gsub!('.', ' ')
    name_string.gsub!(/[^\-\(\)"'\s\p{Alnum}]+/, '')
    name_string.squish!

    parts = name_string.split(' ')
    first, middle, last = nil, nil, nil

    if parts.length >= 3
      first, middle, last = parts[0], parts[1..-2].join(' '), parts.last
    elsif parts.length == 2
      first, last = parts
    else
      last = parts[0]
    end

    return first, middle, last
  end

  def self.split_string(str)
    str.split(/[\b\.]?(?:,\s*|\s+и\s+)+/iu)
  end
end
