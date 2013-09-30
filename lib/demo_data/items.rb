module DemoData

    class Items < ModelCollection

        api_path :items

        IMAGES = Dir.glob("/Users/nas/Pictures/monet/*jpg")

        def initialize( count )
            super()
            ensure_record_count( count ) do
                begin
                    title = FS.product_name
                end while find{| item | item.title == title }
                self.create( title )
            end
        end

        def record_options
            { :include=>['xrefs'] }
        end

        def create( title )
            colors = 0.upto(rand(4)).map{ FS.color }
            sizes  = 0.upto(rand(4)).map{ FS.size }
            xrefs  = []
            colors.each do | color |
                sizes.each do | size |
                    xrefs << { sku_id: DemoData.skus.data.sample.id, options: { color: color, size: size } } unless 0 == rand(5)
                end
            end
            return if xrefs.empty?
            item = super({
                    :title => title,
                    :tags  => DemoData.item_categories.active_tags.sample( rand(3)+1 ),
                    :description => FL.paragraphs( rand(4)+1 ).join('<br>'),
                    :extended_description=> ( 0 == rand(4) ? FL.paragraphs( rand(3)+1 ).join("<br/>") : '' ),
                    :summary => FC.bs + '; ' + FC.catch_phrase,
                    :xrefs_attributes => xrefs,
                    :options=>{:size=>'',:color=>''}
                })

            IMAGES.sample( rand(5)+1 ).map do | image |
                File.open( image ) do | io |
                    DemoData.lb.upload( "items/#{item.id}/images", :image=> io )
                end
            end
        end
    end
end
