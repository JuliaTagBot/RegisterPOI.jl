# RegisterPOI

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.org/yakir12/RegisterPOI.jl.svg?branch=master)](https://travis-ci.org/yakir12/RegisterPOI.jl)
[![codecov.io](http://codecov.io/github/yakir12/RegisterPOI.jl/coverage.svg?branch=master)](http://codecov.io/github/yakir12/RegisterPOI.jl?branch=master)

This is a `Julia` script for registering raw data into a long lasting and coherent data base.

## How to install
1. If you haven't already, install the current release of [Julia](https://julialang.org/) -> you should be able to launch it (some icon on the Desktop or some such).
2. Start Julia -> a Julia-terminal popped up.
3. Copy:
   ```julia
   using Pkg
   pkg"add https://github.com/yakir12/RegisterPOI.jl"
   ```
   and paste it in the newly opened Julia-terminal, press Enter -> this may take a moment.

## How to run

1. Start Julia -> a Julia-terminal popped up.
2. Copy:
   ```julia
   using RegisterPOI
   main()
   ```
   and paste it in the newly opened Julia-terminal, press Enter
3. You'll get some info about how many POIs are left to register, which experiment you're registering next, which run, and which video file contained the calibration for that run. 
4. Which video file did this POI start in? Use your keyboard arrows to navigate across all the already registered video files until you locate the one you need, and press Enter.
5. When in this video did this specific POI start? If the POI moves quickly you'll need to be more accurate (it is possible to achieve millisecond accuracy in most video players), if it's slow or stationary then an accuracy of 1 second is good enough. Any one of these notations will work: 
    - `1` for 1 second
    - `1.000000001` for 1 second and 1 nanosecond (the maximal temporal resolution allowed is a nanosecond)
    - `61` for one minute and one second
    - `1:1` for one minute and one second (note that when including minutes and hours with the colon `:` notation (i.e. `hh:mm:ss.xxxxxxxxx`) make sure there are no more than 59 minutes and 23 hours)
    - `1:1:1` for one hour and one minute and one second
6. Repeat for the stopping video and time of this POI.
7. Specify any comments you might have for that POI.
8. Confirm the addition of this data or undo to return to step #4.

These steps will repeat for each of the POIs in the dataset. All this data is saved to a `RegisterPOI.csv` file in your home directory (hint: type `homedir()` into a Julia terminal to find out what that directory is). To stop registering just press `Ctrl-c`. You can rerun `main()` to resume registering.
