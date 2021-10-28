module RadTest

    import YAML


    struct Outputs
        data::Vector{Any}

        function Outputs(path::String,data::Vector{Any})
            data = YAML.write_file(path,data)
        end
    end
end
