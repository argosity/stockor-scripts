module DemoData

    class Locations < ModelCollection

        api_path 'locations'

        def initialize( count )
            super()
            ensure_record_count( count ) do
                begin
                    code = Faker::Address.city_prefix.upcase
                end while find{| loc | loc.code == code }
                self.create( code )
            end
        end

        def create( code )
            name = Faker::Address.street_name
            super({
                    code: code,
                    name: name,
                    shipping_setting_id: DemoData.shipping_setting.first.id,
                    payment_processor_id: DemoData.payment_processor.first.id,
                    address_attributes: DemoData.make_address( name )
                })
        end
    end
end
