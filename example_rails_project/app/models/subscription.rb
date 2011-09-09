class Subscription < ActiveRecord::Base
  def self.rebill_subscriptions
    puts "Rebilling subscriiptions"
  end
end
