require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
module Import

    class ModelGrabber

        class_attribute :api_path_name
        class_attribute :model_klass


        def initialize( options=self.record_options )
            @data = fetch( self.api_path_name, options )
            @imported = Hash.new
            each do | data |
                record adjust data
            end
        end

        def adjust(data)
            data
        end

        def record(data)
            record = model_klass.create!(data)
            @imported[ data['id'] ] = record
        end

        def remap(hash, old, new)
            hash[new.to_s] = hash.delete(old.to_s)
            hash
        end

        def self.api_path( value )
            self.api_path_name = value
        end

        def self.model(klass)
            self.model_klass=klass
        end

        def record_options
            {}
        end

        def count
            @data.count
        end

        def data
            @data||=[]
        end

        def each( &block )
            @data.each( &block )
        end

        def ensure_record_count( count )
            ( self.data.count + 1 ).upto( count ) do | x |
                Import.log( "%-30s%03i / %03i", self.class, x, count )  if 0 == ( x % 10 )
                yield x
            end
        end

        def first
            self.data.first
        end

        def random_id
            self.data.sample.id
        end

        def find(&block)
            self.data.find(&block)
        end

        def fetch( name=self.api_path_name, options={} )
            query = Import.skr.get( name )
            query.arguments( options.merge( :limit=>250 ) )
            data = parse( query.results )
            fetched = data.count
            Import.log( "%-30s%03d", name, data.count )
            while fetched == 250
                query.arguments({:start=>data.count})
                recs = parse( query.results )
                fetched = recs.count
                data += recs
                Import.log("%-30s%03d", name, data.count )
            end
            data
        end

        def create( attributes, options=self.record_options )
            rec = parse( Import.skr.create( self.api_path_name, attributes, options ), attributes )
            self.data.push( rec )
            rec
        end

        def parse( response, xtra='' )
            if response.success
                response.data
            else
                raise response.message + "\n" + xtra.inspect + "\n"
            end
        end
    end

end
