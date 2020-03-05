using TrustPilotCalc
using Dates, JuliaDB

# load sample dataset and generate yearmon list
example_data = loadtable("../../TrustPlotCalc.jl-old/data/trustpilot_working.csv"; type_detect_rows = 500)
yearmon_list = unique(map(x-> round(x.review_created_at_utc, Dates.Month), example_data))
sort!(yearmon_list; rev = true)
pop!(yearmon_list) # removing last entry to avoid empty arrays

# task channels
c_output = Channel(length(yearmon_list))

function run_through(base_dataset, max_yearmon)
    while true
        result = playBack(base_dataset; max_yearmon = max_yearmon)
        put!(c_output, result)
    end
end

for i in 1:length(yearmon_list)
    @async run_through(example_data, yearmon_list[i])
end

[x for x in c_output]

# [print(playBack(example_data; max_yearmon = x).score, " | ", x, "\n") for x in yearmon_list]
