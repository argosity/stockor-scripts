module Import

    class Terms < ModelGrabber
        api_path :terms

        model Skr::PaymentTerm

        def adjust(data)
            remap(data, :discount_percent, :discount_amount)
        end

    end

end
