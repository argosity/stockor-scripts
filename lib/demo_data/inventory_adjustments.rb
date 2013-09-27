module DemoData


    class InventoryAdjustments < ModelCollection

        api_path :inventory_adjustments

        def initialize
            @reasons = fetch( :inventory_adjustment_reasons )
            @website = fetch( :websites ).first
            lines = []
            DemoData.items.data.each do | item |
                skuloc = DemoData.skus.skuloc_with_location_and_id( @website.location_id, item.xrefs.first.sku_id )
                lines.push( { qty: 1, uom_code: 'EA', uom_size: 1, sku_loc_id: skuloc.id } ) unless skuloc.qty > 0
            end
            create({
                    location_id: @website.location_id,
                    description: "Adjustment to bring in stock for items on demo website",
                    reason_id: @reasons.sample.id,
                    state_event: 'mark_approved',
                    lines_attributes: lines
                }) unless lines.empty?
        end

    end
end
