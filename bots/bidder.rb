## Logs a QuiBids Auction to CSV
#

require 'bidder_model'

## NEW BIDS 
#data
num_bids  = 0
num_skips = 0
last_amt  = -1.0


## AUCTION HOOKS
OnNewAuction = lambda {|auction_name|

  @model = QB_Model.new
  puts "Initialized '#{auction_name}'"
}

OnAuctionEnd = lambda {|auction_name|
  puts "Auction End"
}
  

OnNewBids = lambda {|new_bids|

  @model.process_new_bids new_bids


}



## TIMER THRESHOLD
num_bids = 0
OnTimerThreshold = lambda {|secs, browser|
  if @model.would_bid
    browser.bid
    num_bids += 1
    puts "MODEL SAID TO BID: #{num_bids} so far"
    print "\a"
  else
    num_skips += 1
    puts "MODEL SAID TO SKIP BID: #{num_skips} so far"
  end
}

FourSecondsLeft = lambda {|secs, browser|
  if @model.would_bid
    if rand < 0.07
      puts "Random Bid!"
      browser.bid(true)
    end
  end
}
