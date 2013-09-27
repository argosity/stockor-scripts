module DemoData

    class ShippingSetting < ModelCollection

        api_path :shipping_settings

        def initialize
            super
            ensure_record_count( 1 ) do
                raise "No Shipping Settings were found!"
            end
        end

    end

end
