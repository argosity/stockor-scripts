module DemoData

    class Vendors < ModelCollection

        set_model Skr::Vendor

        def initialize( count )
            super()

            @gl = Skr::GlAccount.default_for(:ap)
            ensure_record_count(count) do
                begin
                    name = FC.name
                    code = Skr::Core::Strings.code_identifier(name)
                end while model.where(code: code ).any?
                create(code, name)
            end
        end

        def create( code, name )
            super({
                    :code                   => code,
                    :name                   => name,
                    :billing_address        => DemoData.make_address(name),
                    :shipping_address       => DemoData.make_address(name),
                    :terms                  => DemoData.terms.random,
                    :notes                  => FC.catch_phrase,
                    :gl_payables_account    => @gl
                })
        end

        # api_path :vendors
        # attr_reader :owner

        # def initialize( count )
        #     super()
        #     @owner = @data.reject!{ |v| "DEMO" == v.code }.first
        #     @pymnt_gl_id = DemoData.gl.find{|gl| gl.number=='2200' }.id
        #     ensure_record_count( count ) do
        #         begin
        #             name = FC.name
        #             code = name.gsub(/\W/,'')[0..6].upcase
        #         end while find{| vendor | vendor.code == code }
        #         self.create( code, name )
        #     end
        # end

        # def create( code, name )
        #     super({
        #             :code                        => code,
        #             :name                        => name,
        #             :account_code                => FC.duns_number,
        #             :website                     => FI.domain_name,
        #             :shipping_address_attributes => DemoData.make_address(name),
        #             :payments_address_attributes => DemoData.make_address(name),
        #             :gl_payables_account_id      => @pymnt_gl_id,
        #             :notes                       => FC.catch_phrase,
        #             :terms_id                    => DemoData.terms.random_id
        #         })
        # end
    end

end
