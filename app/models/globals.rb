module Globals
  CITIES = {
      -1 => I18n.t("cities")[0],
      1 => I18n.t("cities")[2],   # "Москва"
      2 => I18n.t("cities")[3],   # Санкт-Петербург
      14 => I18n.t("cities")[15], # Владивосток
      12 => I18n.t("cities")[13], # Волгоград
      5 => I18n.t("cities")[6],   # Екатеринбург
      15 => I18n.t("cities")[16], # Иркутск
      8 => I18n.t("cities")[9],   # Казань
      16 => I18n.t("cities")[17], # Кемерово
      22 => I18n.t("cities")[23], # Киев
      17 => I18n.t("cities")[18], # Краснодар
      18 => I18n.t("cities")[19], # Красноярск
      4 => I18n.t("cities")[5],   # Нижний Новгород
      3 => I18n.t("cities")[4],   # Новосибирск
      7 => I18n.t("cities")[8],   # Омск
      13 => I18n.t("cities")[14], # Пермь
      10 => I18n.t("cities")[11], # Ростов-на-Дону
      6 => I18n.t("cities")[7],   # Самара
      21 => I18n.t("cities")[22], # Тверь
      19 => I18n.t("cities")[20], # Томск
      11 => I18n.t("cities")[12], # Уфа
      20 => I18n.t("cities")[21], # Хабаровск
      9 => I18n.t("cities")[10],  # Челябинск

      0 => I18n.t("cities")[1], # др. город

  }.freeze


  ABUSES = {
      0 => I18n.t('abuses')[0],
      1 => I18n.t('abuses')[1],
      2 => I18n.t('abuses')[2],
      3 => I18n.t('abuses')[3]
  }.freeze

  ABUSES_REV = ABUSES.invert.freeze

  CITIES_REV = CITIES.invert.freeze #collect {|p| [ p.name, p.id ]

  GENRES = {
      0 => I18n.t("genres")[1], # Business
      1 => I18n.t("genres")[2], # textbook
      2 => I18n.t("genres")[3], # comp&prof.
      3 => I18n.t("genres")[4], # fiction
      4 => I18n.t("genres")[5], # non-fiction
      5 => I18n.t("genres")[6], # kids
      6 => I18n.t("genres")[7], # rare books
      -1 => I18n.t("genres")[0], # Misc
  }.freeze

  GENRES_REV = GENRES.invert.freeze

  OZON_URL = "http://www.ozon.ru/context/detail/id/"
end