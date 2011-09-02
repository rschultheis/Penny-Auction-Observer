#Handles all Interactions with the site/browser through watir
# *Auction stuff it does*
# - Gets timer value (in seconds)
# - Gets bids above a certain bid amt
# - Gets bids that are new since last check
# - Presses the bid button (TODO)
# - Detects auction end (by raising exception)
#

require 'watir-webdriver'


class String
  def pa_calc_amt
    self.sub(/\$/,'').to_f
  end
end


class QB_Site


  def initialize binding_set
    QB_Site.load_biding_set binding_set
  end

  def self.load_biding_set binding_set
    load File.join('site_bindings', "#{binding_set.downcase}.rb")
    include Kernel.const_get binding_set
  end

end


