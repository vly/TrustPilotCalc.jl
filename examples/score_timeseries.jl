using TrustPilotCalc
using Dates, JuliaDB

example_data = loadtable("../../TrustPlotCalc.jl-old/data/trustpilot_working.csv"; type_detect_rows = 500)
yearmon_list = unique(map(x-> round(x.review_created_at_utc, Dates.Month), example_data))
sort!(yearmon_list; rev = true)
pop!(yearmon_list)

[print(playBack(example_data; max_yearmon = x).score, " | ", x, "\n") for x in yearmon_list]
playBack(example_data; max_yearmon = DateTime(2020,01,01))
