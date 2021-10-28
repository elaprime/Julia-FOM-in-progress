
export Config

struct Config
    radials::Vector{Radial}
    soundSpeedNetcdf::String
    bathyGeotiff::String
    outputDirectory::String

    function Config(file::String)
        data = YAML.load_file(file)

        soundSpeedNetcdf = data["soundSpeedNetcdf"]
        bathyGeotiff  = data["bathyGeotiff"]
        outputDirectory = data["outputDirectory"]
        radials = Vector{Radial}()
        for r in data["radials"]
            radial = Radial(r["latitude"], r["longitude"], r["bearing"], r["distance"], r["numberOfPoints"], r["filename"])
            push!(radials, radial)
        end
        new(radials, soundSpeedNetcdf, bathyGeotiff, outputDirectory)
    end
end
