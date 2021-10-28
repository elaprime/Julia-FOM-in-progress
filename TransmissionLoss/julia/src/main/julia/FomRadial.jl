
using GeographicLib
export Radial

struct Radial
    filename::String
    geodesicLine::GeodesicLine
    wayPoints::Vector{NamedTuple{(:lon, :lat, :baz, :dist, :angle), NTuple{5, Float64}}}
    startLatitude::Float64
    startLongitude::Float64
    bearing::Float64
    distance::Float64

    function Radial(lat::Float64, lon::Float64, b::Float64, d::Float64, n::Int64, filename::String)
        geodesicLine = GeodesicLine(lon, lat, azi=b, dist = d)
        wayPoints = waypoints(geodesicLine; n=n)
        new(filename, geodesicLine, wayPoints, lat, lon, b, d)
    end
end


