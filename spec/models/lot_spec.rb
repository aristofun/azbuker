# coding: utf-8
require 'spec_helper'

describe Lot do
  it { should have_attached_file(:cover) }
  it { should validate_attachment_size(:cover).
                      less_than(4.megabytes) }

  after(:all) do
    FileUtils.rm_rf(Dir["#{Rails.root}/public/system/covers/"])
  end

  describe "cover UPLOADs" do


    it "should Use correct cover uploaded" do
      lambda do
        lt = FactoryBot.create(:lot,
                                :cover => Rails.root.join("spec/fixtures/no_resize_original.png")
                                .open)
        lt.should be_valid
        lt.cover.should be_present
        FileTest.exist?(lt.cover.path).should be_truthy
        FileTest.exist?(lt.cover.path(:x300)).should be_truthy
        FileTest.exist?(lt.cover.path(:x200)).should be_truthy
        FileTest.exist?(lt.cover.path(:x120)).should be_truthy
        lt.cover.url.should =~ /^\/system\/covers\/lots-\d\/\d\/\d{3}\/\d{3}\/\w{43}_original.jpg(\?\d+)?$/
        lt.cover.url(:x300).should =~ /^\/system\/covers\/lots-\d\/\d\/\d{3}\/\d{3}\/\w{43}_x300.jpg(\?\d+)?$/
        lt.cover.url(:x200).should =~ /^\/system\/covers\/lots-\d\/\d\/\d{3}\/\d{3}\/\w{43}_x200.jpg(\?\d+)?$/
        lt.cover.url(:x120).should =~ /^\/system\/covers\/lots-\d\/\d\/\d{3}\/\d{3}\/\w{43}_x120.jpg(\?\d+)?$/
      end.should change(Lot, :count).by(1)
    end

    it "should reject wrong filesize&type&dimensions" do
      lambda do
        lt = FactoryBot.build(:lot, :cover => Rails.root.join("spec/factories/lot_factory.rb").open)
        lt.should_not be_valid
        lt.errors.get(:cover_content_type).should_not be_empty

        lt = FactoryBot.build(:lot, :cover => Rails.root.join("spec/fixtures/huge_picture.jpg").open)
        lt.should_not be_valid
        lt.errors.get(:cover_file_size).should_not be_empty

        lt = FactoryBot.build(:lot, :cover => Rails.root.join("spec/fixtures/too_small_dimensions.tiff").open)
        #puts lt.errors.inspect
        lt.should_not be_valid
        lt.errors.get(:cover).should_not be_empty

        lt = FactoryBot.create(:lot,:cover => Rails.root.join("spec/fixtures/almost_huge.jpg").open)
        lt.should be_valid
      end.should change(Lot, :count).by(1)
    end

    it "should do correct resize" do
      cover = Rails.root.join("spec/fixtures/no_resize_original.png").open
      dims = dimensions(cover)
      lt = FactoryBot.create(:lot, :cover => cover)
      dimensions(lt.cover).to_s.should == dims.to_s
      dimensions(lt.cover.path(:x300)).to_s.should == "200x300"
      dimensions(lt.cover.path(:x200)).to_s.should == "200x200"
      dimensions(lt.cover.path(:x120)).to_s.should == "120x120"

      cover2 = Rails.root.join("spec/fixtures/minimal_dimensions.gif").open
      dims = dimensions(cover2)
      lt2 = FactoryBot.create(:lot, :cover => cover2)
      dimensions(lt2.cover).to_s.should == dims.to_s
      dimensions(lt2.cover.path(:x300)).to_s.should == "200x300"
      dimensions(lt2.cover.path(:x200)).to_s.should == "200x200"
      dimensions(lt2.cover.path(:x120)).to_s.should == "120x120"
    end

    it "should Use default cover urls if no file uploaded" do
      lt = FactoryBot.create(:lot)
      lt.should be_valid
      lt.cover.url.should == "/covers/missing_original.png"
      lt.cover.url(:x300).should == "/covers/missing_x300.png"
      lt.cover.present?.should be_falsey
    end
  end

  describe "creation" do
    it "should create good lots" do
      auth = Author.from_string("  \tГлеб    Архангельский ")
      book = FactoryBot.create(:book)
      book.authors << auth
      book.save
      usr = FactoryBot.create(:user)

      lambda do
        lot = FactoryBot.create(:lot, :book => book, :price => 120, :can_deliver => true,
                                 :can_postmail => false,
                                 :comment => "Привет пацаны!", :user => usr)
        lot.should be_valid
        lot.book.id.should == book.id
        lot.book.authors[0].short.should == "Г. Архангельский"
        lot.user.id.should == usr.id
        lot.can_deliver.should be_truthy
        lot.can_postmail.should be_falsey
        lot.comment.should == "Привет пацаны!"
        lot.price.should == 120
      end.should change(Lot, :count).by(1)
    end

    it "should update phone&skype&city if differ" do
      book = FactoryBot.create(:book_w_author)
      user = FactoryBot.create(:user)

      lot2 = FactoryBot.create(:lot, :book_id => book.id, :user_id => user.id,
                                :skypename => "some_skype", :phone => "495 777 5588", :cityid => 567)
      lot2.read_attribute(:skypename).should == "some_skype"
      lot2.skypename.should == "some_skype"
      lot2.read_attribute(:cityid).should == 567
      lot2.cityid.should == 567
      lot2.phone.should == "495 777 5588"
      lot2.read_attribute(:phone).should == "495 777 5588"
    end

    it "should inherit phone&skype&city from user" do
      book = FactoryBot.create(:book_w_author)
      user = FactoryBot.create(:user)

      lot = FactoryBot.create(:lot, :book_id => book.id, :user_id => user.id)
      lot.read_attribute(:phone).should be_blank
      lot.read_attribute(:skypename).should be_blank
      lot.phone.should == user.phone
      lot.skypename.should == user.skypename
      lot.cityid.should_not be_blank
    end
  end

  describe "cache counter updates" do
    it "should update Book.min_price" do
      book = FactoryBot.create(:book_w_author)
      book.min_price.should == 0 # default value

      lot1 = FactoryBot.create(:lot, :book_id => book.id, :price => 17)
      book.reload
      book.min_price.should == 17

      lot2 = FactoryBot.create(:lot, :book_id => book.id, :price => 4)
      book.reload
      book.min_price.should == 4

      lot3 = FactoryBot.create(:lot, :book_id => book.id, :price => 0)
      lot4 = FactoryBot.create(:lot, :book_id => book.id, :price => 2)

      book.reload
      book.min_price.should == 0
      book.lots_count.should == 4

      lot3.is_active = false
      lot3.save

      book.reload
      book.min_price.should == 2
      book.lots_count.should == 3

      lot4.destroy

      book.reload
      book.min_price.should == 4
      book.lots_count.should == 2

      lot3.is_active = true
      lot3.save

      book.reload
      book.min_price.should == 0
      book.lots_count.should == 3
    end

    it "should increment/decrement Book.lots_count" do
      book = FactoryBot.create(:book_w_author)
      book.lots_count.should == 0

      lot = FactoryBot.create(:lot, :book_id => book.id)
      book.reload
      book.lots.should == [lot]
      book.lots_count.should == 1

      22.times do
        book.lots << FactoryBot.create(:lot, :book_id => book.id)
      end
      book.reload
      book.lots.count.should == 23
      book.lots_count.should == 23
      book.lots.include?(lot).should be_truthy

      4.times do
        lot = book.lots.delete_at(0)
        lot.destroy
      end
      book.reload
      book.lots_count.should == 19
      book.lots.length.should == 19
      book.lots.active.length.should == 19

      15.times do
        lot = book.lots.delete_at(0)
        lot.is_active = false
        lot.save
      end

      book.reload
      book.lots.active.count.should == 4
      book.lots_count.should == 4
      #puts book.lots.to_sql
      book.lots.count.should == 19
      #p book.lots.map(&:is_active)

      i = 0
      book.lots.each do |lot_|
        unless lot_.is_active
          lot_.is_active = true
          lot_.save
          i += 1
        end
        break if i >= 9
      end

      book.reload
      book.lots.count.should == 19
      book.lots.active.count.should == 13
      book.lots_count.should == 13

      book.lots.active.map(&:destroy)

      book.reload
      book.lots.count.should == 6 # 19 - 13, that we destroyed
      book.lots.active.count.should == 0
      book.lots_count.should == 0

      book.lots.map(&:destroy)

      nlot = FactoryBot.create(:lot)
      nlot.is_active = false
      nlot.book_id = book.id
      nlot.save
      book.reload
      book.lots_count.should == 0
      book.lots.should == [nlot]

      nlot.is_active = true
      nlot.save
      book.reload
      book.lots_count.should == 1
      book.lots.should == [nlot]

      nlot.is_active = false
      nlot.save
      nlot.book_id = 777
      nlot.is_active = true
      nlot.save

      book.reload
      book.lots_count.should == 0
      book.lots.should == []
    end

  end
end
