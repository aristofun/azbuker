# encoding: UTF-8
require 'rubygems'
require 'logger'
require 'mechanize'

#trap("INT") { BookRetriever.kill }
#trap("KILL") { BookRetriever.kill }
#trap("TERM") { BookRetriever.kill }
#trap("ABRT") { BookRetriever.kill }

#def finish
#  puts "Interrupted at " + Time.now.to_s
#  @robot.stopp
#end


class BookRetriever
  #attr_reader :log_time, :log_count
  FOLDER = "#{Rails.root}/public/system/ozbooks/"

  def self.run(test=false)
    @@robot = BookRetriever.new(test)
    @@robot.go!
  end

  def logger
    @loger ||= (@test_mode ? Logger.new(STDOUT) : Rails.logger)
  end


  def initialize(test_mode = false, proxy = nil)

    unless proxy.nil?
      @proxy, @port = proxy.split(" :")
    end
    @test_mode = test_mode
    @counter = read_counter
    @not_found_counter = 0
    puts "Libring counting up from " + @counter.to_s
    logger.info("Libring book count up from " + @counter.to_s)

    @agent = Mechanize.new()
    @agent.log = logger # use rails logger
    #@agent.log.level = 1 unless @test_mode # info mode
    @agent.log = nil if @test_mode

    @libring = "http://www.libring.ru/books/"
    @agent.follow_meta_refresh = true
    @agent.set_proxy(@proxy, @port) unless @proxy.nil?
    @agent.keep_alive = false
    @agent.user_agent = "Opera/9.80 (Windows NT 5.1; U; en) Version/10.1"

    @log_time = [Time.now]
    @log_count = [@counter]
  end

  def stopp
    @is_running = false
    dump_state
    stat_file
  end

  def read_counter
    puts "init current counter file"

    File.open("#{FOLDER}counter.txt", "r") do |file|
      file.readline().to_i
    end
  end

  def dump_state
    File.open("#{FOLDER}counter.txt", "w") do |file|
      file.puts @counter-1 unless @counter.nil?
    end
  end

  def stat_file
    @log_time << Time.now
    @log_count << @counter

    File.open("#{FOLDER}stat.txt", "w") do |file|
      secs = (@log_time[1] - @log_time[0])
      dumpstr = "BOOK_STAT: time: #{(secs/1.minute).round(1)} min., avg. speed: #{(@log_count[1] - @log_count[0]) /secs} books/se c."
      file.puts dumpstr
      logger.info "\n#{dumpstr}\n"
    end

    @log_time = [Time.now]
    @log_count = [@counter]
  end

  def increment_counter
    @counter += 1 #unless @test_mode
    # @counter = rand(2400000) if @test_mode
  end

  def go!
    @is_running = true

    while @counter > -1 && @is_running
      # save current state and ++ libring book counter
      dump_state if (@counter % 41) == 0
      stopp if (@counter % 33 == 0) && File.exist?("#{FOLDER}stop")
      stat_file if (@counter % 351 == 0)
      increment_counter
      sleep 1.271 + rand*1.1 # acting like human being

      # getting the new libring book
      libring_bookurl = @libring + @counter.to_s
      retries = 0

      begin
        # read body
        page = @agent.get(libring_bookurl)
        #we goto OZON book page

        # old template
        # link = page.link_with(:href => /shop=ozon&id=(\d+)/iu)

        # http://www.libring.ru/books/goShop/24570068?shop=1
        link = page.link_with(:href => /goShop\/(\d+)\?shop=1$/iu)

        if link.nil? || page.body.mb_chars.downcase.include?("Издательство: Книга по Требованию".mb_chars.downcase) # no ozon link on libring page! OR contains     Издательство: Книга по требованию
          puts "__SKIP: #{libring_bookurl}"
          next
        end

        ozonid = get_ozonid(link.href)

        if ozonid.blank?
          puts "__SKIP: #{libring_bookurl}"
          next
        end

        page = @agent.get("#{Globals::OZON_URL}#{ozonid}/")

        logger.info "#{libring_bookurl} -> #{page.uri.to_s}"
        #refresh ozonid just in case if ozon redirect happened
        ozonid = get_ozonid(page.uri.to_s)
        book = OzonBookParser.new(ozonid, page, @agent)

        if book.parse_book!
          logger.debug "#{book}"
          OzBook.create_from_ozon_book!(book) unless @test_mode
        else
          puts "__BOOK2SKIP: #{book.bookid}, libringid: #{@counter}" if book.should_skip?
          next if book.should_skip?
          raise Exception.new
        end

        # successfully eaten – restart retry & 404 counters
        @not_found_counter = 0
        retries = 0
      rescue Exception => e
        puts("__ERROR on #{libring_bookurl}: " + e.message)
        # logger.error("__ERROR on #{libring_bookurl}: " + e.message)
        # quit retriever if book not found
        if e.is_a?(Mechanize::ResponseCodeError) && e.response_code == '404'
          logger.error "__NOT_FOUND_404: goto next book"
          @not_found_counter += 1

          if @not_found_counter >= 55 # finished
            logger.warn "__NOT_FOUND_404: #{@not_found_counter} times on bookid:#{@counter}"
            @counter = @counter - @not_found_counter
            stopp
            break
          end
          next
        end

        logger.debug e.backtrace if @test_mode
        # any other errors
        sleep 20
        if retries < 12
          retries += 1
          retry
        else
          puts("__ 20 retries reached on #{libring_bookurl}: " + e.inspect)
          # logger.error("__ 20 retries reached on #{libring_bookurl}: " + e.inspect)
          UserMailer.tech_error(
              "book retriever fail #{libring_bookurl} ozon: #{ozonid}",
              "#{e.message}  \n\n #{e.inspect} \n\n #{e.backtrace}"
          ).deliver
          next
        end
      end
    end
  end

  private
  def get_ozonid(i)
    # old templates
    # ozonmatch = /shop=ozon&id=(?<ozonid>\d+)/iu.match(i)
    ozonmatch = /goShop\/(?<ozonid>\d+)\?shop=1$/iu.match(i)
    ozonmatch = /id\/(?<ozonid>\d+)/iu.match(i) if ozonmatch.blank?
    ozonmatch[:ozonid] if ozonmatch.present?
  end

end

#def main_loop(count)
#  @robot = BookRetriever.new(0, true)
#  @robot.go!
#  sleep 3
#  finish
#end

