module DemoData

    class PaymentProcessor < ModelCollection

        api_path 'payment_processors'

        def initialize
            super
            ensure_record_count( 1 ) do
                raise "No Payment Processor was found!"
            end
        end

    end

end
