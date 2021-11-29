using UnderwaterAcoustics
using Plots
using NetCDF
using GeoArrays
using GeographicLib
using YAML

include("FomRadial.jl")
include("FomConfig.jl")
include("Fn_Idxs.jl")

configFile = "C:/NRL/Git/gitlab/julia-fom/TransmissionLoss/julia/src/test/resources/emily.yml";
inputs = Config(configFile);
print(inputs);

depth = ncread(inputs.soundSpeedNetcdf,"depth");
soundSpeed = ncread(inputs.soundSpeedNetcdf,"sound_speed");
latitudes_all = ncread(inputs.soundSpeedNetcdf, "lat");
longitudes_all = ncread(inputs.soundSpeedNetcdf, "lon");



bathyGrid = GeoArrays.read(inputs.bathyGeotiff);
bathyDepths = [[],[],[]] #needs to be dynamic
ranges = []
bathyVector = [[],[],[]] #needs to be dynamic
bathy2 = []

for i = 1:1:length(inputs.radials)
    for j = 1:1:length(inputs.radials[i].wayPoints)
        dist = inputs.radials[i].wayPoints[j].dist;
        push!(ranges,dist)
    
        latitudes = inputs.radials[i].wayPoints[j].lat;
        longitudes = inputs.radials[i].wayPoints[j].lon;

        idxb = indices(bathyGrid, (longitudes,latitudes));
        bathyVector = bathyGrid[idxb[1],idxb[2]];
        bathy = bathyVector[1];
            if bathy === missing
                bathy = 0
            end
        bathy = abs(bathy);
        push!(bathyDepths[i], bathy)
    end
end 

#gets indices for lat/lon for each Radial
#finds SSP for all depths along that lat/lon
idxs = []
for i = 1:length(inputs.radials)
    idxss = Idxs(inputs.radials[i],latitudes_all,longitudes_all);
    push!(idxs, idxss)
end

ssp_vec = []
for i = 1:length(idxs)
        ssp_vec1 = soundSpeed[idxs[i][2],idxs[i][1],:,1];
        push!(ssp_vec,ssp_vec1)
end

ssp_depths = range(0,maximum(bathyDepths[1]),length=40)


env = UnderwaterEnvironment(
    seasurface = Vacuum,
    seabed = SandyClay,
    ssp = SampledSSP(ssp_depths, ssp_vec[1]),
    bathymetry = SampledDepth(1.0:125.0:5000, bathyDepths[1])
)

pm = Bellhop(env; gaussian=true);
tx = AcousticSource(0.0,-50.0,1000.0);
rx = AcousticReceiverGrid2D(1,5,1000,-5000,25,200);
x = transmissionloss(pm,tx,rx);
plot(env;receivers=rx,transmissionloss=x)





















# depth = ncread( soundSpeedNetcdf["netcdf"], "depth")
# soundspeed = ncread(soundSpeedNetcdf["netcdf"],"sound_speed")
# latitudes = ncread(soundSpeedNetcdf["netcdf"],"lat")
# longitudes = ncread(soundSpeedNetcdf["netcdf"],"lon")

#bathyGrid = GeoArrays.read(inputs["bathyGeotiff"])

# radials = []

# value = values(inputs["radials"])

# for i in length(inputs["radials"]) #length of radials object from inputs
#     #bearing1 += bearing_inc
#     radial = FOM.FOM.Radial(value[i]["latitude"], value[i]["longitude"], value[i]["bearing"], value[i]["distance"], value[i]["numberOfPoints"])
#     push!(radials, radial)
# end


# outputs = RadTest.RadTest.Outputs("C:\\NRL\\Git\\gitlab\\julia-fom\\TransmissionLoss\\src\\outputDirectory\\rad_test.yml",radials)


# bathy_depths = []
# ranges =[]
# runningRange = 0
# idx = []
# bathyVector = []


# #for j in 1:1:length(radials2)

# for k = 1:1:length(radials)
#     #need to get indices for ssp (only for 1st waypoint), graph ssp, vector of 40 depths, 1D
#     pnt = radials[k].waypt[k]
#     idx = indices(bathyGrid, (longitudes[k],latitudes[k]))
#     bathyVector = bathyGrid[idx[1],idx[2]]
#     bathy2 = bathyVector[1]
#     if bathy2 === missing
#         bathy2 = 0
#     end
#     bathy2 = abs(bathy2)
#     push!(bathy_depths, bathy2)
#     push!(ranges, runningRange)
#     runningRange += 914.4
# end

# println(size(ranges), size(bathy_depths))

# range_vec=round.(Int,ranges)

# ssp_depths = range(0,maximum(bathy_depths),length=40)
# env = UnderwaterEnvironment(
#     seasurface = Vacuum,
#     seabed = SandyClay,
#     #ssp = SampledSSP(0.0:20.0:40.0, [1540.0, 1510.0, 1520.0], :smooth),
#     #ssp = SampledSSP(depth3, ssp1latlon, :linear),
#     #ssp = SampledSSP(1:1:40,ss2[1,1,:,1]),
#     ssp = SampledSSP(ssp_depths,ss2[1,1,:,1]),
#     #ssp = IsoSSP{Vector{Float64}}(ss2[1,1,:,1]),
#     #ssp = IsoSSP{Float64}(ss2[600,500,20,1]),
#     bathymetry = SampledDepth(ranges, bathy_depths, :linear))
#     #bathymetry = SampledDepth(0.0:50.0:100.0, [40,35.0,38.0], :linear))

# pm = Bellhop(env;gaussian=true)
# tx = AcousticSource(0.0,-5.0,1000.0)
# rx = AcousticReceiverGrid2D(0.0,range_vec[2]/10,500, -maximum(bathy_depths),29.5,200)
# x = transmissionloss(pm,tx,rx)
# Plots.plot(env; receivers=rx,transmissionloss=x,ylim=[-6000,0], xlim = [10,25000])
