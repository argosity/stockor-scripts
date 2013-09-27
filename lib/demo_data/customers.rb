module DemoData

    class Customers < ModelCollection

        api_path :customers

        def initialize( count )
            super()
            @recv_gl_id = DemoData.gl.find{|gl| gl.number=='1200' }.id
            ensure_record_count( count ) do
                begin
                    name = FC.name
                    code = name.gsub(/\W/,'')[0..6].upcase
                end while find{| customer | customer.code == code }
                self.create( code, name )
            end
        end

        def create( code, name )
            super({
                    :code                    => code,
                    :name                    => name,
                    :mail_address_attributes => DemoData.make_address(name),
                    :phys_address_attributes => DemoData.make_address(name),
                    :terms_id                => DemoData.terms.random_id,
                    :notes                   => FC.catch_phrase,
                    :ship_partial            => rand(4) > 1,
                    :is_tax_exempt           => 0 == rand(4),
                    :gl_receivables_account_id => @recv_gl_id
                })
        end
    end
end
