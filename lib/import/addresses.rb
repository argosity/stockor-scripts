module Import

    class Addresses < ModelGrabber
        api_path :address

        model Skr::Address

        def adjust(data)
            remap(data, :zip, :postal_code)
        end

    end
end
