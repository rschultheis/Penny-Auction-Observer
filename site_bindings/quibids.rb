require 'watir-webdriver'
require 'hpricot'

#this module implements
module QUIBIDS

  @browser = nil
  @last_amt = nil
  @auction_els = nil
  @logged_in = false

  def start auction_id
    @auction_id = auction_id if auction_id

    @browser = Watir::Browser.new 'firefox'
    goto_auction
  end

  def goto_auction
    @browser.goto "http://quibids.com/auctions/#{@auction_id}"
  end

  def auction_name
    name = @browser.title.split(' -')[0]
    puts "auction name is '#{name}'"
    name
  end

  def initialize_auction
    #init some data
    @last_amt = -1.0
    @auction_els = {
      :timer            => @browser.p(:class => 'large-timer2'),
      :history          => @browser.table(:id => 'bid-history'),
      #:bid_btn		=> @browser.link(:class => /^bid/	    ),
      :bid_btn		=> @browser.link(:text => "Bid Now"),
    }

    #confirm all the elements are accessible
    @auction_els.each_pair do |name, el|
      puts "Checking #{name}"
      (0...5).each do |i|
        #break if el.exist? && el.visible?
        break if el.exist?
        puts "not found on attempt #{i}"
        sleep 1.0
      end
      puts "Found #{name}"
    end

    puts "Bid Btn: #{@auction_els[:bid_btn].html}"
  end

  def refresh_auction
    @browser.refresh
    checks = 0
    while not(@auction_els[:timer].exist?)
      sleep 0.5
      checks += 1
      raise "Refresh failed to find auction again?!" if checks > 20
    end
    while ( @auction_els[:timer].text !~ /\d\d:\d\d:\d\d/ )
      sleep 0.5
      checks += 1
      raise "Refresh failed to find auction again?!" if checks > 20
    end
  end

  def bid(force=false)
    sleep 0.1  #this pause can be tweaked to give better last second catches
    if force || (seconds_left < 3)
      if @logged_in
        @auction_els[:bid_btn].click
        puts "BID clicked!"
      else
        puts "BID would be clicked if logged in!"
      end
    else
      puts "SKIPPED BID at the last second because timer went up"

    end
  end

  def seconds_left
    begin
      timer_str = @auction_els[:timer].text
    rescue Selenium::WebDriver::Error::ObsoleteElementError
      puts "Timer text retrieval failed, breifly pausing and retrying..."
      sleep 0.1
      timer_str = @auction_els[:timer].text
    end

    unless timer_str.match /\d\d:\d\d:\d\d/
      #puts "got timer string: '#{timer_str}'"
      raise "Not a timer string" if timer_str =~ /\S/
    end
    h, m, s = timer_str.split(':').map{|n| n.to_i}
    (h * 3600) + (m * 60) + (s)
  end


  def get_new_bids
    bids = []

    #to do this reliably is tricky, the table moves, 
    #so going row-by-row / cell-by-cell with webdriver calls will cause accuracy issues
    # instead, just pull out a snapshot of the html, and parse that out
    # its actually faster this way too, and very accurate
    hdoc = Hpricot(@auction_els[:history].html)

    hdoc.search('//tr').reverse.each do |tr|
      bidder, amt, type = tr.search('//td').map {|tr| tr.inner_html}[1..3]
      amt = amt.pa_calc_amt
      type = (type == 'BidOMatic') ? :automatic : :manual
      if amt > @last_amt
        bids << {
          :bidder => bidder,
          :amt => amt,
          :type => type,
          }
        @last_amt = amt
      end
    end
    bids
  end

  def login username, password
    @browser.text_field(:name, 'username').set username
    @browser.text_field(:name, 'password').set password
    @browser.button(:id, 'login').click
    goto_auction
    @logged_in = true
  end

end
