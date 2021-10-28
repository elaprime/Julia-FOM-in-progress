export Idxs

function Idxs(rad::Radial, lat::Vector{Float64}, lon::Vector{Float64})
    st_lat = rad.startLatitude
    st_lon = rad.startLongitude

    #println(st_lat)
    #println(st_lon)
    idx_lat = findall(x->x==st_lat, lat)
    #println(idx_lat)
    idx_lon = findall(x->x==st_lon, lon)
    #println(idx_lon)
  
    idx_lat = convert(Int,idx_lat[1])
    idx_lon = convert(Int,idx_lon[1])
    
    idxssp = [idx_lat,idx_lon]
    return idxssp
end

