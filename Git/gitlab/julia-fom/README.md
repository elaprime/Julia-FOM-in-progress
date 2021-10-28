# Julia FOM
### A model in development to calculate transmission loss based off of an environment with a single sound speed profile and bathymetry data along the radial


# Setup

## 1. Install Atom
Download, install, and open [Atom](https://atom.io/).

## 2. Install [Juno](https://docs.junolab.org/stable/man/installation/).

## 3. Use Juno
Open REPL with `Juno > Open REPL` then press `Enter` in the REPL to start a Julia session

## 4. Install [UnderwaterAcoustics.jl](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/index.html).
      julia>]
      pkg> add UnderwaterAcoustics

## 5. Install [Bellhop](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/index.html)
You must first install [OALIB Bellhop](http://oalib.hlsresearch.com/AcousticsToolbox/) and ensure you have `bellhop.exe` available on your `PATH`. The Bellhop model will usable if `UnderwaterAcoustics` can find `bellhop.exe`.
___

# Getting Started

This example utilizes [GeoArrays.jl](https://github.com/evetion/GeoArrays.jl), [GeographicLib.jl](https://github.com/anowacki/GeographicLib.jl), [NetCDF.jl](https://github.com/JuliaGeo/NetCDF.jl), [UnderwaterAcoustics.jl](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/index.html), and [Plots.jl](http://docs.juliaplots.org/latest/).

Define packages used

      using UnderwaterAcoustics
      using Plots
      using NetCDF
      using GeographicLib
      using GeoArrays

read in NetCDF files

      depth2 = ncread("C:\\john\\data\\depthdata.nc","depth")
      ss2 = ncread("C:\\john\\data\\sspdata.nc","sound_speed")
      lat = ncread("C:\\john\\data\\lat.nc","lat")
      lon = ncread("C:\\john\\data\\lon.nc","lon")

read in GeoTIFF file

      bathy = GeoArrays.read("C:\\john\\data\\bathy.tiff")

create a [`GeodesicLine`](https://anowacki.github.io/GeographicLib.jl/dev/julia_funcs/#GeographicLib.GeodesicLines.GeodesicLine-Tuple{Geodesic,%20Any,%20Any}) and find [`waypoints`](https://anowacki.github.io/GeographicLib.jl/dev/julia_funcs/#GeographicLib.waypoints) along the radial at one `lat` and one `lon`

      line = GeodesicLine(lon[12], lat[12], azi=0, dist=92600)
      wpts = waypoints(line, dist=914.4)


collect bathymetry data from `waypoints`

      depths = []
      ranges = []
      runningRange = 0
      idx = []
      bathyVector = []

      for k = 1:1:81
          pnt = wpts[k]
          idx = indices(bathy, (pnt.lon,pnt.lat))
          bathyVector = bathy[idx[1],idx[2]]
          bathy2 = bathyVector[1]
          if bathy2 === missing
              bathy2 = 0
          end    
          bathy2 = abs(bathy2)
          push!(depths, bathy2)
          push!(ranges, runningRange)
          runningRange += 914.4
      end

create an `UnderwaterEnvironment`

      env = UnderwaterEnvironment(
          seasurface = Vacuum,
          seabed = SandyClay,
          ssp = IsoSSP{Float64}(ss2[70,50,30,1]),
          bathymetry = SampledDepth(ranges, depths, :linear))

create [`Bellhop`](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/pm_api.html#UnderwaterAcoustics.Bellhop-Tuple{Any}) model

      pm = Bellhop(env; gaussian=true)

define a [source](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/pm_api.html#UnderwaterAcoustics.AcousticSource-NTuple{4,Any}) and a [receiver](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/pm_api.html#UnderwaterAcoustics.AcousticReceiverGrid2D-NTuple{6,Any})

      tx = AcousticSource(0.0,-5,1000.0)
      rx = AcousticReceiverGrid2D(1,.1,1000, -20,.1,200)

calculate [`transmissionloss`](https://org-arl.github.io/UnderwaterAcoustics.jl/stable/pm_api.html#UnderwaterAcoustics.transmissionloss)

      x = transmissionloss(pm,tx,rx)

plot the transmission loss, using the `reverse()` method to plot correctly

      Plots.plot(env; receivers=rx,transmissionloss=reverse(x;dims=2), ylim = [-20,0])

![Transmission loss](/NRL/data/TL_7_27.jpg)

***An issue regarding inverted plots from Bellhop has been opened [here](https://github.com/org-arl/UnderwaterAcoustics.jl/issues/31?_pjax=%23js-repo-pjax-container)***
