module DemoData

    class ItemCategories < ModelCollection

        TAGS = %w{  animals   architecture   art   asia   australia   autumn   baby   band    beach    bike   birds   birthday   black   blue   car   cat   china  church   city   clouds   color   concert   dance   day   dog   england   europe   fall   family   fashion   festival   film   florida   flower   flowers   food   football   france   friends   fun   garden  germany   girl   graffiti   green   halloween   hawaii   holiday   house   india    island   italy   japan   kids    lake   landscape   light   live   london   love   mexico   model   museum   music   nature   new   newyork  night    ocean   old   paris   park   party   people   photo portrait    red   river   rock   scotland   sea   seattle   show   sky   snow   spain   spring   square    street   summer   sun    taiwan   texas   thailand   tokyo   travel   tree   trees   trip    urban   usa   vacation   vintage   washington   water   wedding   white   winter  }

        api_path :item_categories

        def initialize( count )
            super()
            ensure_record_count( count ) do
                begin
                    name = FS.department
                end while find{| cat | cat.name == name }
                self.create( name )
            end
        end

        def active_tags
            @chosen_tags ||= self.data.map{|ic| ic.include_tags }.flatten.uniq
        end

        def create( name )
            super( {
                    :name => name,
                    :description  => FC.bs.titleize, active: true,
                    :include_tags => TAGS.sample( rand(8)+1 ),
                    :exclude_tags => TAGS.sample( rand(3)+1 ),
                })
        end
    end
end
