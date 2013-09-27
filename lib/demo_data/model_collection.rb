require 'active_support/core_ext/class/attribute_accessors'
require 'active_support/core_ext/class/attribute'
module DemoData

    class ModelCollection

        class_attribute :api_path_name

        def self.api_path( value )
            self.api_path_name = value
        end

        def initialize
            @data = fetch
        end

        def data
            @data||=[]
        end

        def ensure_record_count( count )
            self.data.count.upto( count - 1 ) do | x |
                yield x
            end
        end

        def first
            self.data.first
        end

        def random_id
            self.data.sample.id
        end


        def update( id, attrs )
            DemoData.lb.update( self.api_path_name, id, attrs ) do | resp |
                p resp
            end
        end

        def find(&block)
            self.data.find(&block)
        end

        def fetch( name=self.api_path_name, options={} )
            query = DemoData.lb.get( name )
            query.include( options[:include] ) if options.has_key?(:include)
            parse( query.results )
        end

        def create( attributes, params={} )
            rec = parse( DemoData.lb.create( self.api_path_name, attributes, params ), attributes )
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
