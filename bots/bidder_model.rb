
class QB_Model
  def initialize
    @bids = []
    @bidders = {}

    @num_bids = 0
    @last_amt = 0.00

    @uniques = {:u10 => 10, :u20 => 20}
    @autoq = 9999
  end

  def process_new_bids new_bids
    new_bids.each do |bid|
      
      @bids << bid

      if @bidders.has_key? bid[:bidder]
        @bidders[bid[:bidder]][:count] += 1
      else
        @bidders[bid[:bidder]] = {
		:count => 1
	}
      end
       
      @num_bids += 1
      #puts "NEW BID #{@num_bids}\t #{bid[:bidder]}\t #{bid[:amt]}\t #{bid[:type]}\t #{bid[:last_secs]}\t:: #{@bidders[bid[:bidder]][:count]} so far"
      printf("NEW BID %4d: %15s(%4d bids) %3.2f %15s - %2d seconds remaining\n",@num_bids, bid[:bidder], @bidders[bid[:bidder]][:count], bid[:amt], bid[:type], bid[:last_secs])
    end

   ##determine unique bidders 
    @uniques = {}
    bidders = @bids.reverse.map{|b| b[:bidder]}
    @uniques[:u10] = bidders[0, 10].uniq.length
    @uniques[:u20] = bidders[0, 20].uniq.length
    @uniques[:u30] = bidders[0, 30].uniq.length
    @uniques[:u40] = bidders[0, 40].uniq.length
    @uniques[:u50] = bidders[0, 50].uniq.length

    puts "Uniques: #{@uniques.inspect}"


    ##determine ratio of Auto to Manual
    types = @bids.reverse.map{|b| b[:type]}

    @autoq = 0
    plus = 10
    while (plus > 0)
      @autoq += plus if types[10-plus] == :automatic
      plus -= 1
    end

    puts "AUTO Q: #{@autoq}"

    @last_amt = new_bids.last[:amt] if new_bids.length > 0
    puts "Processed #{new_bids.length} new bids"
  end

  def would_bid

    #return false if @num_bids < 25
    return false if @uniques[:u10] > 8
    #return false if @uniques[:u20] > 9
    #return false if (@autoq > 40) && (@uniques[:u10] > 3)

    return true
  end
end

