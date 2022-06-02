cd(@__DIR__)
cd("..")
using Pkg; Pkg.activate("."); Pkg.instantiate()

using DataFrames, CSV
using Statistics: mean
using Queryverse
using Dates


url = "https://raw.githubusercontent.com/globaldothealth/monkeypox/main/latest.csv"
download(url, "data/monkeypox_data.csv")
df = DataFrame(CSV.File("data/monkeypox_data.csv"))

df = df |>
    @filter(_.Status=="confirmed")|>
    @orderby(_.Country) |>
    @orderby(_.Date_confirmation) |>
    DataFrame

    df = df |>
    @groupby(_.Country)|>
    DataFrame
    @groupby(_.Date_confirmation) |>
    @map({Date_confirmation=key(_), Count_infected=length(_)}) |>
    @filter(!isna(_.Date_confirmation)) |>
    DataFrame 

firstDate = df.Date_confirmation[1]
lastDate = df.Date_confirmation[end]
dr = collect(firstDate:Dates.Day(1):lastDate)
dic = Dict(Pair.(df.Date_confirmation, df.Count_infected))

infectedNew = []
for i in 1:length(dr)
    if in.(dr[i], [Set(df.Date_confirmation)]) == Bool[1]
        push!(infectedNew, dic[dr[i]])
    else
        push!(infectedNew, 0)
    end
    
end

infectedTotal = [0]
for i in 1:length(infectedNew)
    push!(infectedTotal, infectedTotal[i]+infectedNew[i])
end
infectedTotal = infectedTotal[2:end]

dataSet = DataFrame(date = dr,
                    infectedNew = infectedNew,
                    infectedTotal = infectedTotal
                    )

CSV.write("data/monkeypox_time_serie.csv", dataSet)
movingaverage(g, n) = [i < n ? mean(g[begin+n÷2:i+n÷2]) : mean(g[i+n÷2-n+1:i]) for i in 1+n÷2:length(g)];