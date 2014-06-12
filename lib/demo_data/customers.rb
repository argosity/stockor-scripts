module DemoData

    class Customers < ModelCollection

        set_model Skr::Customer

        def initialize( count )
            super()

            @gl = Skr::GlAccount.default_for(:ar)
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
                    :gl_receivables_account => @gl
                })
        end
    end

end
