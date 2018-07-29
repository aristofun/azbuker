# coding: utf-8
# Date: 29.07.12
# Time: 13:41

class AzbUtils

  MAIN_FILE = "azbuker_main"
  OZB_FILE = "azbuker_oz_books"
  DB = "azbuk_prod"

  def self.pgdump_string(db, table, file)
    #"su - joe -c \"pg_dump -U postgres -h localhost -c #{table} #{db} | bzip2 -c > #{file}\""
    "pg_dump -U postgres -h localhost -c #{table} #{db} | bzip2 -c > #{file}"
  end

  def self.upload_string(file)
    "./dropbox_uploader.sh upload #{file} Apps/azb_upload/#{file}"
  end
end