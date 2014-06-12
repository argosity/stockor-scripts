require 'skr/core'
require_relative 'stockor_client'

require_rel 'import/*.rb'
module Import

    mattr_accessor :skr, :addresses, :gl, :terms, :payment_processor, :shipping_setting, :locations, :vendors, :skus
    mattr_accessor :item_categories, :items, :purchase_orders, :customers, :sales_orders, :adjustment

    def self.log( str, *args )
        STDOUT.puts str % args
    end

    def self.run( skr )
        Skr::Core::DB.connect({ adapter: 'postgresql',  database: 'skr_dev' })
        self.skr = skr
        ActiveRecord::Base.transaction do
            self.terms = Terms.new
            self.addresses = Addresses.new
            raise ActiveRecord::Rollback.new
        end
    end

end
