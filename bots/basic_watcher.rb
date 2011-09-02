## Logs a QuiBids Auction to STDOUT
#

## NEW BIDS 
#data
num_bids = 0
last_amt = -1.0

## AUCTION HOOKS
OnNewAuction = lambda {|auction_name|
  last_amt = -1.0
  num_bids = 0
  puts "Now watching new auction: #{auction_name}"
}

OnAuctionEnd = lambda {|auction_name|
  puts "Done watching auction: #{auction_name}"
}
  

OnNewBids = lambda {|new_bids|
  new_bids.each do |bid|
    num_bids += 1
    puts "NEW BID: '#{bid[:bidder]}' : '#{bid[:amt]}' : '#{bid[:type]}' : #{bid[:last_secs]} : #{last_amt}"
  end
  last_amt = new_bids.last[:amt] if new_bids.count > 0
  puts "Processed #{new_bids.count} new bids"
}



## TIMER THRESHOLD
num_hits = 0
OnTimerThreshold = lambda {|secs, browser|
  #browser.bid
  num_hits += 1
  puts "TIMER THRESHOLD HIT: #{num_hits} so far"
}
