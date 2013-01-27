## Logs a QuiBids Auction to CSV
#

## NEW BIDS 
#data
num_bids = 0
last_amt = -1.0

### HELPERS
def init_csv filename
  unless File.directory? 'csv'
    Dir.mkdir 'csv'
  end
  filename = 'csv/' + filename + '.' + Time.now.strftime("%m%d%Y_%H%M") + '.csv'
  @csv_writer = File.open(filename, 'w')
  puts "Opened csv '#{filename}'"
end

def write_csv line_array
  str = ""
  line_array.each {|f| str += "#{f.to_s}, "}
  @csv_writer.puts str.sub(/, $/,'')
end


## AUCTION HOOKS
OnNewAuction = lambda {|auction_name|
  last_amt = -1.0
  num_bids = 0
  init_csv auction_name
}

OnAuctionEnd = lambda {|auction_name|
  @csv_writer.close
  puts "Closed csv"
}
  

OnNewBids = lambda {|new_bids|
  new_bids.each do |bid|
    num_bids += 1
    puts "NEW BID: '#{bid[:bidder]}' : '#{bid[:amt]}' : '#{bid[:type]}' : #{bid[:last_secs]} : #{last_amt}"
    write_csv [num_bids, Time.now.strftime("%H:%M:%S"), bid[:amt], bid[:bidder], bid[:type], bid[:last_secs], last_amt]
  end
  last_amt = new_bids.last[:amt] if new_bids.count > 0
  puts "Processed #{new_bids.count} new bids"
}



## TIMER THRESHOLD
num_hits = 0
OnTimerThreshold = lambda {|secs, browser|
  #browser.bid
  num_hits += 1
  puts "TIMER HIT: #{num_hits} so far"
  #print "\a"
}
