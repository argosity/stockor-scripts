require_relative 'demo_data/model_collection'
require_relative 'demo_data/gl_accounts'
require_relative 'demo_data/terms'
require_relative 'demo_data/payment_processor'
require_relative 'demo_data/shipping_setting'
require_relative 'demo_data/locations'
require_relative 'demo_data/vendors'
require_relative 'demo_data/customers'
require_relative 'demo_data/skus'
require_relative 'demo_data/item_categories'
require_relative 'demo_data/items'
require_relative 'demo_data/purchase_orders'
require_relative 'demo_data/inventory_adjustments'
require_relative 'demo_data/sales_orders'
require_relative 'ledger_buddy'
require 'active_support/core_ext/module/attribute_accessors'
require 'faker'

module DemoData

    UOMS = [['PALLET',1000],['CASE',100],['BOX',20],['EA',1]].map{|code,size| Hashie::Mash.new(code:code,number:size)}

    (FI,FA,FP,FC,FN,FS,FL) = [
        Faker::Internet, Faker::Address, Faker::PhoneNumber, Faker::Company,
        Faker::Name,  Faker::Commerce, Faker::Lorem
    ]

    def self.make_address( name = FN.name )
        {   :name=>name, :email=>FI.email, :phone=>FP.phone_number,
            :line1=>FA.street_address, :city=>FA.city, :state=>FA.state_abbr, :zip=>FA.zip_code }
    end

    mattr_accessor :lb, :gl, :terms, :payment_processor, :shipping_setting, :locations, :vendors, :skus
    mattr_accessor :item_categories, :items, :purchase_orders, :customers, :sales_orders, :adjustment

    def self.log( str, *args )
        STDOUT.puts str % args
    end

    def self.run( lb )
        Kernel.srand()
        self.lb = lb
        self.gl                = GLAccounts.new
        self.terms             = Terms.new
        self.payment_processor = PaymentProcessor.new
        self.shipping_setting  = ShippingSetting.new
        self.locations         = Locations.new( 3 )
        self.vendors           = Vendors.new( 120 )
        self.skus              = Skus.new( 350 )
        self.customers         = Customers.new( 220 )
        self.purchase_orders   = PurchaseOrders.new
        self.sales_orders      = SalesOrders.new( 200 )
        self.item_categories   = ItemCategories.new( 6 )
        self.items             = Items.new( 90 )
        self.adjustment        = InventoryAdjustments.new
    end

end
