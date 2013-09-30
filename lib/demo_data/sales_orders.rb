module DemoData

    class SalesOrders < ModelCollection

        api_path 'sales_orders'

        def initialize( count )
            super()
            ensure_record_count( count ) do
                self.create
            end

            fetch( self.api_path_name, :scope=>{:pickable=>true},:include=>["lines"]).each do | so |
                pick(so) unless ( 0 == rand(5) )
            end
        end

        def record_options
            { :include=>['lines'] }
        end

        def create
            location_id = DemoData.locations.random_id
            lines = []

            count = rand(14)+1
            DemoData.skus.for_location( location_id ) do | sku, sl |
                lines.push( { sku_loc_id: sl.id, qty: rand(20)+1 } ) unless sku.is_other_charge
                break if 0 == count-=1
            end
            return if lines.empty?

            super({
                    customer_id: DemoData.customers.random_id,
                    po_num: FS.product_number,
                    location_id: location_id,
                    lines_attributes: lines
                })

        end

        def pick( so )
            pt = parse( DemoData.lb.get( 'pick_tickets/from_orders' )
                    .arguments( :order_ids=>[so.id] )
                    .include('lines')
                    .results
                ).first
            unless ( 0 == rand(10) )
                invoice( pt )
            end
        end

        def invoice( pt )
            parse( DemoData.lb.create( 'invoices', {
                        pick_ticket_id: pt.id,
                        amount_paid: ( 0 == rand(2) ) ? pt.lines.inject(0){|sum,ptl| sum+(ptl.price.to_f * ptl.qty.to_i) } : 0.0,
                        lines_attributes: pt.lines.map{ | ptl |
                            { pt_line_id: ptl.id, qty: ptl.qty }
                        }
                    }, { :include=>['lines'] } ) )
        end
    end
end
