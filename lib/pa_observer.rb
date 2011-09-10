# This class watches an auction

require 'pa_site'

class QB_Observer
  def initialize pa_site
    @pa_site = pa_site

    @hooks = {}  #contains lambdas which are called in observice auction loop
  end

  attr_accessor :hooks

  def auction_name
    @pa_site.auction_name
  end

  def process_event name, *args
    @hooks[name].call(*args) if @hooks.has_key? name
  end

  def get_new_bids
    enhanced_bids = @pa_site.get_new_bids
    enhanced_bids.each {|b| b[:last_secs] = @last_secs }
    enhanced_bids
  end

  def observe_auction
    @pa_site.initialize_auction

    process_event :on_new_auction, auction_name

    #DATA USED IN LOOP
    cur_secs = 0
    @last_secs = -1
    secs_since_refresh = 0

    while ( true )
      begin
        cur_secs = @pa_site.seconds_left
      rescue
        puts $!
        break
      end
     
      #If the timer changed since last observation 
      if (cur_secs != @last_secs )

        #If the timer is almost out (bid)
        if cur_secs < 2
          process_event :on_timer_threshold, cur_secs, @pa_site
        end

        puts " - " + cur_secs.to_s

        #If the timer went up, then we have new bids to process
        if (cur_secs > @last_secs )
          #Need to refresh the browser periodically to prevent inactivity popups
          if secs_since_refresh > 900
            @pa_site.refresh_auction
            secs_since_refresh = 0
          end

          #keep getting new bids until there isn't any left to get, sometimes the time spent in new bid event is enough for new bids to show up... dont want to wait until another bid
          new_bids = get_new_bids
          while (new_bids.count > 0)
            process_event :on_new_bids, new_bids
            sleep 1.0
            secs_since_refresh += 1
            @last_secs = cur_secs
            new_bids = get_new_bids
          end

        end

        #refresh the browser periodically to prevent innactivity popups
        secs_since_refresh += 1
      end

      @last_secs = cur_secs
      sleep 0.05
    end
    puts "End of Auction"
    process_event :on_auction_end, auction_name
  end

end

