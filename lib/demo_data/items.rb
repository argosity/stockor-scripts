module DemoData

    class Items < ModelCollection

        api_path :items

        IMAGES = Dir.glob("/Users/nas/Pictures/monet/*jpg")

        def initialize( count )
            @data = fetch( self.api_path_name, :include=>['xrefs'])
            ensure_record_count( count ) do
                begin
                    title = FS.product_name
                end while find{| item | item.title == title }
                self.create( title )
            end
        end

        def create( title )
            xrefs = DemoData.skus.data.sample( rand(3)+1 ).map do | sku |
                { sku_id: sku.id, options: { color: FS.color, size: FS.size } }
            end
            item = super({
                    :title => title,
                    :tags  => DemoData.item_categories.active_tags.sample( rand(3)+1 ),
                    :description => FL.paragraphs( rand(4)+1 ).join('<br>'),
                    :extended_description=> ( 0 == rand(4) ? FL.paragraphs( rand(3)+1 ).join("<br/>") : '' ),
                    :summary => FC.bs + '; ' + FC.catch_phrase,
                    :xrefs_attributes => xrefs,
                    :options=>{:size=>'',:color=>''}
                }, {:include=>['xrefs']} )

            IMAGES.sample( rand(5)+1 ).map do | image |
                File.open( image ) do | io |
                    DemoData.lb.upload( "items/#{item.id}/images", :image=> io )
                end
            end
        end
    end
end
