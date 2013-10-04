module DemoData


    class Skus < ModelCollection

        BINS =  (1..333).to_a.map{|x| ["A", "B", "C", "D"].sample + ( '%03i' % x ) }

        api_path :skus

        def initialize( count )
            super()
            @gaa_id = DemoData.gl.find{|gl| gl.number=='5100' }.id
            ensure_record_count( count ) do | x |
                digits = ( '%04i' % x )
                desc = FS.product_name
                cost = rand(10000).to_f / 100
                vendors = DemoData.vendors.data.sample( rand(3)+1 ).map do | vendor |
                    cost = cost * 1.1
                    uom = UOMS.sample
                    { vendor_id: vendor.id, code: FS.product_number, list_price: cost*1.45,
                      uom_size: uom.number, uom_code: uom.code, cost: cost }
                end
                locations = DemoData.locations.data.sample( rand(DemoData.locations.count)+2 ).map do | loc |
                    { location_id: loc.id, bin: BINS.sample }
                end
                0.upto( rand(10) ) do
                    color = FS.color
                    code =  digits + color[0..2].upcase
                    self.create( code, color.capitalize + ' ' + desc, vendors, locations ) unless find{|sku| sku.code == code }
                end
            end
        end

        def record_options
            { :include=>['locations','sku_vendors'] }
        end

        def active_vendor_ids
            @active_vendors ||= self.data.map{|sku| sku.sku_vendors.map(&:vendor_id) }.flatten.uniq
        end

        def skuloc_with_location_and_id( location_id, sku_id )
            sku = @data.find{ |s| sku_id == s.id }
            raise "Looking for Sku ID #{sku_id} but server didn't return it" unless sku
            return sku.locations.find{|l| l.location_id == location_id } ||
                DemoData.lb.get( 'sku_locs' ).query( sku_id: sku_id, location_id: location_id ).first ||
                parse( DemoData.lb.create( 'sku_locs', { sku_id: sku_id, location_id: location_id }) )
        end

        def for_location( location_id )
            self.data.each do | sku |
                sl = sku.locations.find{ | rec | rec.location_id == location_id }
                yield [sku, sl] if sl
            end
        end

        def for_vendor_and_location( vendor_id, location_id, &block )
            self.data.each do | sku |
                sv = sku.sku_vendors.find{ | rec | rec.vendor_id == vendor_id }
                sl = sku.locations.find{   | rec | rec.location_id == location_id }
                if sv && sl
                    yield [ sku, sv, sl ]
                end
            end
        end

        def create( code, description, vendors, locations )
            price = vendors.last[:list_price]
            super({
                    code: code, description: description,
                    gl_asset_account_id: @gaa_id, default_uom_code: 'EA', bin: BINS.sample,
                    does_track_inventory: true, is_other_charge: false, is_discontinued: false,
                    uoms_attributes: [{
                            base_price: price, code:'EA', size: 1, weight: (rand(750).to_f/10)+0.2,
                            width: (rand(50).to_f/10)+0.2, height: (rand(60).to_f/10)+0.2, depth: (rand(80).to_f/10)+0.2
                        }],
                    sku_vendors_attributes: vendors,
                    locations_attributes: locations
            })
        end
    end

end
