module DemoData

    class PurchaseOrders < ModelCollection

        api_path :purchase_orders

        def initialize( count )
            @data = fetch( self.api_path_name, :include=>['lines'])

            ensure_record_count( count ) do
                self.create
            end

        end

        def create
            location_id = DemoData.locations.random_id
            vendor_id   = DemoData.skus.active_vendor_ids.sample
            lines = []

            count = rand(14)+1
            DemoData.skus.for_vendor_and_location( vendor_id, location_id ) do | sku, sv, sl |
                lines.push( { sku_loc_id: sl.id, qty: rand(20)+1 } ) unless sku.is_other_charge
                break if 0 == count-=1
            end
            return if lines.empty?
            po = super({
                    vendor_id: vendor_id,
                    location_id: location_id,
                    lines_attributes: lines
                },{:include=>['lines']})

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

            if ( 0 == rand(2) )
                DemoData.lb.update( 'vouchers', vouch.id, { state_event: 'mark_confirmed' } )
            end

        end

    end
end
