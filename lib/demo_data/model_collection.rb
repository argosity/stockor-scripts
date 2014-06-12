require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'

module DemoData

    class ModelCollection

        class_attribute :api_path_name
        class_attribute :model

        def initialize(options=self.record_options)
            #@data = fetch( self.api_path_name, options )
        end

        def self.api_path( value )
            self.api_path_name = value
        end

        def self.set_model(klass)
            self.model=klass
        end

        def record_options
            {}
        end

        def count
            model.count
        end


        def ensure_record_count( count )
            (self.count + 1).upto( count ) do | x |
                DemoData.log( "%-30s%03i / %03i", self.class, x, count )  if 0 == ( x % 10 )
                yield x
            end
        end

        def first
            self.data.first
        end

        def random
            model.order('random()').first
        end

        def create(attributes)
            model.create!(attributes)
        end

        # def update( id, attrs )
        #     DemoData.skr.update( self.api_path_name, id, attrs ) do | resp |
        #         p resp
        #     end
        # end

        # def find(&block)
        #     self.data.find(&block)
        # end

        # def fetch( name=self.api_path_name, options={} )

        #     query = DemoData.skr.get( name )
        #     query.arguments( options.merge( :limit=>250 ) )
        #     data = parse( query.results )
        #     fetched = data.count
        #     DemoData.log( "%-30s%03d", name, data.count )
        #     while fetched == 250
        #         query.arguments({:start=>data.count})
        #         recs = parse( query.results )
        #         fetched = recs.count
        #         data += recs
        #         DemoData.log("%-30s%03d", name, data.count )
        #     end
        #     data
        # end

        # def create( attributes, options=self.record_options )
        #     rec = parse( DemoData.skr.create( self.api_path_name, attributes, options ), attributes )
        #     self.data.push( rec )
        #     rec
        # end

        # def parse( response, xtra='' )
        #     if response.success
        #         response.data
        #     else
        #         raise response.message + "\n" + xtra.inspect + "\n"
        #     end
        # end

    end

end
