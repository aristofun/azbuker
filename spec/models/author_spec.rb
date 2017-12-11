#coding: utf-8
require 'spec_helper'

describe Author do
  describe "Author.from_string" do
    before(:each) do
      Author.delete_all
    end

    it "should process many part names" do
      lambda do
        # Pushkin A. S. -> A. S. Pushkin
        auth1 = Author.from_string("Маркиз д сад")
        auth2 = Author.from_string("Маркиз де франсуа хренмонде сад")
        auth1.id.should == auth2.id
        auth2.full.should == "Маркиз Де Франсуа Хренмонде Сад"
        # Turgenev Ivan -> Ivan Turgenev
        auth3 = Author.from_string("киш-кин")
        auth4 = Author.from_string("сергей мадлобротский писюхатый киш-кин")
        auth5 = Author.from_string("с м киш-кин")
        auth4.id.should == auth3.id
        auth5.id.should == auth3.id
        auth5.full.should == "Сергей Мадлобротский Писюхатый Киш-Кин"
      end.should change(Author, :count).by(2)
    end

    it "should restore correct FML sequence" do
      lambda do
        # Pushkin A. S. -> A. S. Pushkin
        auth1 = Author.from_string("Фадей Гонопольский  ")
        auth2 = Author.from_string("Гонопольский  Ф. М. ")
        auth22 = Author.from_string("Гонопольский  Ф")
        auth1.id.should == auth2.id
        auth22.id.should == auth2.id
        auth2.full.should == "Фадей М Гонопольский"
        # Turgenev Ivan -> Ivan Turgenev
        auth3 = Author.from_string("I.Sergeich Turgenev")
        auth4 = Author.from_string("Turgenev Ivan S.")
        auth4.id.should == auth3.id
        auth4.full.should == "Ivan Sergeich Turgenev"
      end.should change(Author, :count).by(2)

      auth1 = Author.from_string("I. Mikluho-Маклай")
      auth2 = Author.from_string("Mikluho-Маклай Salem. I.")
      auth1.id.should_not == auth2.id
      auth2.full.should == "Salem I Mikluho-Маклай"

      auth3 = Author.from_string("Ivan И") # should not retrieve I-lastname
      auth4 = Author.from_string("И Ivan S") # should not retrieve I-lastname
      auth4.full.should == "И Ivan S"
    end

    it "should retrieve different object for diff FML-name" do
      lambda do
        auth1 = Author.from_string("Фадей Гонопольский  ")
        auth2 = Author.from_string("Фадей ираклиевич        гонопольский")
        auth1.id.should == auth2.id

        auth3 = Author.from_string("Фадей ирак        гонопольский")
        auth3.id.should_not == auth2.id
        # older authors first
        auth4 = Author.from_string("Ф и        гонопольский")
        auth5 = Author.from_string("  ф. гонопольский")
        auth6 = Author.from_string("гонопольский")

        auth6.full.should == "Фадей Ираклиевич Гонопольский"
        auth5.id.should == auth1.id
        auth4.id.should == auth1.id

        auth7 = Author.from_string("Ф. ирак        гонопольский")
        auth7.id.should == auth3.id
        auth7.full.should == "Фадей Ирак Гонопольский"

        auth8 = Author.from_string("Фадей Гонопольский Ирак")
        auth9 = Author.from_string("   ф. г.  иРАК")
        auth8.id.should == auth9.id #!!
      end.should change(Author, :count).by(3)
    end

    it "should update author names" do
      lambda do
        auth1 = Author.from_string("  пуШкин ")
        auth2 = Author.from_string("А ПУшкин")
        auth1.id.should == auth2.id
        # extend with F
        auth1 = Author.from_string(" пушкин ")
        auth2 = Author.from_string("  а.пушкин ")
        auth1.id.should == auth2.id
        auth1.full.should == "А Пушкин"
        auth2.first.should == "А"
        # extend with First
        auth3 = Author.from_string("Александр пушкин ")
        auth4 = Author.from_string("  а. ПушкиН. ")
        auth5 = Author.from_string("  А пушКИн ")
        auth3.id.should == auth4.id
        auth5.id.should == auth3.id

        auth5.full.should == "Александр Пушкин"
        auth4.first.should == "Александр"
        # add M
        auth6 = Author.from_string("А.С.пушкин ")
        auth6.id.should == auth4.id
        auth6.full.should == "Александр С Пушкин"
        auth7 = Author.from_string("  а.Пушкин ")
        auth8 = Author.from_string("  пУшКин ")
        auth7.id.should == auth6.id
        auth8.id.should == auth7.id

        auth8.full.should == "Александр С Пушкин"
        auth7.middle.should == "С"

        # add Middle
        auth9 = Author.from_string("А.\tсергеевич   пушкин ")
        auth9.id.should == auth8.id
        auth9.full.should == "Александр Сергеевич Пушкин"

        auth10 = Author.from_string("    а.Пушкин ")
        auth13 = Author.from_string("  Александр сергЕЕвич Пушкин ")
        auth12 = Author.from_string("  аЛександр.Пушкин ")
        auth11 = Author.from_string("\t\t  пушкин ")
        auth10.id.should == auth9.id
        auth11.id.should == auth10.id
        auth12.id.should == auth10.id
        auth13.id.should == auth10.id

        auth11.full.should == auth9.full
      end.should change(Author, :count).by(1)
    end

    it "should retrieve equal objects" do
      lambda do
        auth1 = Author.from_string("пу'(шкин")
        auth2 = Author.from_string(" Пу'(шкин")
        auth3 = Author.from_string("пу'(шкин    ")

        auth1.id.should == auth2.id
        auth2.id.should == auth3.id
      end.should change(Author, :count).by(1)

      lambda do
        auth1 = Author.from_string("    а.пушкин")
        auth2 = Author.from_string("    АлЕКсандр Пушкин")
        auth3 = Author.from_string("А. С.пушКИН")
        auth4 = Author.from_string("   А.Пушкин  ")

        auth1.id.should == auth2.id
        auth2.id.should == auth3.id
        auth3.id.should == auth4.id
      end.should change(Author, :count).by(1)

      lambda do
        auth1 = Author.from_string("   александр Кирилыч.мушкин")
        auth2 = Author.from_string("А      кирилыч Мушкин")
        auth3 = Author.from_string(" Александр.к. мушкин")
        auth4 = Author.from_string(" А.    К.Мушкин")
        auth5 = Author.from_string(" А.    Мушкин")
        auth6 = Author.from_string(" Мушкин")

        auth1.id.should == auth2.id
        auth2.id.should == auth3.id
        auth3.id.should == auth4.id
        auth5.id.should == auth4.id
        auth6.id.should == auth5.id
        auth6.full.should == "Александр Кирилыч Мушкин"
      end.should change(Author, :count).by(1)
    end
  end

  describe "full-short name generator" do
    it "should create right full/short name" do
      au0 = Author.create(:last => "пуШкин'")
      au0.full.should == "Пушкин'"
      au0.short.should == "Пушкин'"
      au0.should be_valid

      au1 = Author.create(:last => " ПуШкин' ", :first => " \tИВАН ")
      au1.full.should == "Иван Пушкин'"
      au1.short.should == "И. Пушкин'"
      au1.should be_valid

      au3 = Author.create(:last => "  пу-   щщИн ", :middle => "  оле'Г")
      au3.full.should == "Оле'Г Пу- Щщин"
      au3.short.should == "О. Пу- Щщин"
      au3.should be_valid

      au2 = Author.create(:last => "пу-щщИн", :middle => "  оле'Г")
      au2.full.should == "Оле'Г Пу-Щщин"
      au2.short.should == "О. Пу-Щщин"
      au2.should be_valid

      au4 = Author.create(:last => "'иванов", :middle => "  олеГ", :first => " СергеевиЧ")
      au4.full.should == "Сергеевич Олег 'Иванов"
      au4.short.should == "С. О. 'Иванов"
      au4.should be_valid

      au5 = Author.create(:last => "тютчев", :middle => "andreyevich  ", :first => "   ")
      au5.full.should == "Andreyevich Тютчев"
      au5.short.should == "A. Тютчев"
      au5.should be_valid
    end
  end

  describe "validations" do
    it "should reject the same full_name" do
      Author.create(:last => "Пушкин").should be_valid
      Author.create(:last => "Пушкин", :first => "саша").should be_valid
      Author.create(:last => "пушкен").should be_valid
      Author.new(:last => "пушкИн").should_not be_valid
      Author.new(:last => "пУШкин.").should_not be_valid
      Author.new(:last => "пушкин", :first => " Саша  ").should_not be_valid
    end

    it "should accept right symbols" do
      lambda do
        Author.create(:last => "i").should be_valid
        Author.create(:last => "Ваня").should be_valid
        Author.create(:last => "Ваня-старший-младший").should be_valid
        Author.create(:last => "Ваня-старший (младший) А Плиний").should be_valid
        Author.create(:last => "Д'Эладжио\"Инаят А Хан").should be_valid

        Author.create(:last => "Thomas'", :first => "", :middle => "").should be_valid
        Author.create(:last => "Пушкин", :first => "Алекс", :middle => "Сергеич").should be_valid
        Author.create(:last => "Thomas'Э", :first => "Альфа", :middle => "эдисон").should be_valid
        Author.create(:last => "ThomaЗ'", :middle => "Иванови-ч'").should be_valid
        Author.create(:last => "Thomas", :middle => "Ива\"нови-(ч)").should be_valid

        Author.create(:last => "Thomas(", :first => "Ива\"нови-(ч)").should be_valid
      end.should change(Author, :count).by(11)
    end

    it "should reject shit symbols" do
      lambda do
        Author.create(:last => "").should_not be_valid
        Author.create(:last => "  ").should_not be_valid
        Author.create(:last => "пушкен#").should_not be_valid
        Author.create(:last => "пушкен<").should_not be_valid
        Author.create(:last => "пушкен   $  ").should_not be_valid
        Author.create(:last => "пушкен", :first => "D'Artan&jan").should_not be_valid
        Author.create(:last => "пушкен", :first => "D'Artan$Гена").should_not be_valid
        Author.create(:last => "пушкен", :first => "Drtan>Гена").should_not be_valid
        Author.create(:last => "пушкен", :first => "Гена.").should_not be_valid
        Author.create(:last => "пушкен", :first => ".Гена").should_not be_valid
        Author.create(:last => "пушкен", :middle => "D'Artan#jan").should_not be_valid
        Author.create(:last => "пушкен", :middle => "D'Artan Гена").should be_valid # we allow
                                                                                    #complex
                                                                                    #middlenames
        Author.create(:last => "пушкен", :middle => "Drtan<Гена").should_not be_valid
        Author.create(:last => "пушкен", :middle => "Гена.").should_not be_valid
        Author.create(:last => "пушкен", :middle => ".Гена").should_not be_valid
      end.should change(Author, :count).by(1) # the olny valid author with complex middlename
    end
  end
end
