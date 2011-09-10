#!/usr/bin/env ruby
require 'optparse'
#require 'rubygems'


#Deal with the cmd line
def parse_cmd_line
  options = {
      :hooks_file => 'bots/csv_logger.rb',
      :site => 'QUIBIDS',
      :login => false,
  }

  optparse = OptionParser.new do |opts|
    opts.banner = %Q|
      Penny Auction Observer

      example: ruby -I lib bin/pa_auction_but.rb bots/csv_logger.rb
    |

    opts.on("-b", "--bot-file=FILE_NAME",
      "specify the bot file to execute, default is '#{options[:hooks_file]}'") { |filename| options[:hooks_file] = filename}

    opts.on("-a", "--auction-id=AUCTION_ID",
    "the auction id") { |id| options[:auction_id] = id }

    opts.on("-s", "--site=SITE",
      "Specify the site to use, default is '#{options[:site]}'") { |site| options[:site] = site}

    opts.on("-l", "--login=username:password",
      "Specify username and password to login with, otherwise no username or password will be used") { |str|

          (options[:username], options[:password]) = str.match(/^(.+):(.+)$/)[1,2]

          options[:login] = true
      }

  end
  optparse.parse!
  options
end
options = parse_cmd_line

## Take care of loading the libraries... not sure if this is the best way but it works...
BASE_DIR = File.dirname(File.dirname($0))
LIB_DIR = File.join(BASE_DIR, 'lib')
BOTS_DIR = File.join(BASE_DIR, 'bots')
$: << LIB_DIR << BOTS_DIR

require 'pa_site'
require 'pa_observer'

#setup the auction observerobject object
auction_id = options[:auction_id]
load options[:hooks_file]

pa_site = QB_Site.new options[:site].upcase
pa_site.start auction_id

pa_site.login(options[:username], options[:password]) if options[:login]

auction_observer = QB_Observer.new pa_site

auction_observer.hooks[:on_new_bids]    = OnNewBids
auction_observer.hooks[:on_new_auction] = OnNewAuction
auction_observer.hooks[:on_auction_end] = OnAuctionEnd
auction_observer.hooks[:on_timer_threshold] = OnTimerThreshold

auction_observer.observe_auction
