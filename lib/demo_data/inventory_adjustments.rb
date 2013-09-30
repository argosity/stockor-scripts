module DemoData


    class InventoryAdjustments < ModelCollection

        api_path :inventory_adjustments

        def initialize
            @reasons = fetch( :inventory_adjustment_reasons )
            @website = fetch( :websites ).first
            lines = []
            skus  = []
            DemoData.items.data.each do | item |
                xref = item.xrefs.first
                next if xref.nil? || skus.include?( xref.sku_id )
                skuloc = DemoData.skus.skuloc_with_location_and_id( @website.location_id, xref.sku_id )
                next if skuloc.qty.present? && skuloc.qty > 0
                skus << xref.sku_id
                raise skuloc unless skuloc.id
                lines.push( { qty: 1, uom_code: 'EA', uom_size: 1, sku_loc_id: skuloc.id } )
            end
            create({
                    location_id: @website.location_id,
                    description: "Adjustment to bring in stock for items on demo website",
                    reason_id: @reasons.sample.id,
                    state_event: 'mark_applied',
                    lines_attributes: lines
                }) unless lines.empty?
        end

    end
end
