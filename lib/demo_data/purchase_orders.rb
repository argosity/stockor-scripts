module DemoData

    class PurchaseOrders < ModelCollection

        api_path :purchase_orders

        def initialize
            super()
            return if data.count != 0
            DemoData.vendors.each do | vendor |
                DemoData.locations.data.sample( rand( DemoData.locations.count ) + 1 ).each do | location |
                    self.create( vendor, location )
                end
            end
        end

        def record_options
            { :include=>['lines'] }
        end

        def create( vendor, location )
            lines = []
            DemoData.skus.for_vendor_and_location( vendor.id, location.id ) do | sku, sv, sl |
                lines.push( { sku_loc_id: sl.id, qty: rand(20)+1 } ) unless sku.is_other_charge
            end
            return if lines.empty?
            po = super({
                    vendor_id: vendor.id,
                    location_id: location.id,
                    lines_attributes: lines
                })

            unless ( 0 == rand(5) )
                receive(po)
            end
        end

        def open
            @open ||= self.data.select{|po| 'received' != po.status }
        end

        def receive(po)
            vouch = parse( DemoData.lb.create( 'vouchers', {
                        purchase_order_id: po.id,
                        refno: FS.product_number,
                        lines_attributes: po.lines.map{ | pol |
                            { po_line_id: pol.id, qty: ( pol.qty - pol.qty_received), auto_allocate: true }
                        }
                } ) )

            if ( 0 == rand(5) )
                DemoData.lb.update( 'vouchers', vouch.id, { state_event: 'mark_confirmed' } )
            end

        end

    end
end
