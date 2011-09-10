require 'watir-webdriver'

#this module implements
module QUIBIDS

  @browser = nil
  @last_amt = nil
  @auction_els = nil

  def start auction_id
    @auction_id = auction_id if auction_id

    @browser = Watir::Browser.new 'firefox'
    goto_auction
  end

  def goto_auction
    @browser.goto "http://quibids.com/auctions/#{@auction_id}"
  end

  def auction_name
    name = @browser.title
    puts "auction name is '#{name}'"
    name
  end

  def initialize_auction
    #init some data
    @last_amt = -1.0
    @auction_els = {
      :timer            => @browser.div(:class => /timer2/	    ),
      :history          => @browser.div(:id => 'bidding-history' ).table,
      #:bid_btn		=> @browser.link(:class => /^bid/	    ),
      :bid_btn		=> @browser.link(:id => "button_#{@auction_id}"	    ),
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

  def bid
    sleep 0.1  #this pause can be tweaked to give better last second catches
    if seconds_left < 3
      @auction_els[:bid_btn].click
      puts "BID clicked!"
    else
      puts "SKIPPED BID at the last second.... timer didn't look ready'"

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


   #improve this, have it parse static html to improve the data capture and eliminate live updating problem
  def get_new_bids
    cur_amt = @last_amt
    bids = []
    @auction_els[:history].hashes.reverse.each do |bid_row|
      new_bid = {
                :bidder	=> bid_row['BIDDER'],
                :amt	=> bid_row['BID'].pa_calc_amt,
                :type	=> bid_row['TYPE'] =~ /BidOMatic/ ? :automatic : :manual,
              }
      if new_bid[:amt] > @last_amt
        bids << new_bid
        @last_amt = new_bid[:amt]
      end
    end
    bids
  end

  def login username, password
    @browser.text_field(:name, 'username').set username
    @browser.text_field(:name, 'password').set password
    @browser.button(:id, 'login-btn').click
    goto_auction
  end

end