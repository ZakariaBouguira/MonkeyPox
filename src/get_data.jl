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
    @filter(!isna(_.Date_confirmation)) |>
    #@orderby(_.Country) |>
    @orderby(_.Date_confirmation) |>
DataFrame

function timeSeries(df)
    df= df |>
        @groupby(_.Date_confirmation) |>
        @orderby(_.Date_confirmation) |>
        @map({Date_confirmation=key(_), Count_infected=length(_)}) |>
    DataFrame
    firstDate = df.Date_confirmation[1]
    lastDate = df.Date_confirmation[end]
    dr = collect(firstDate:Dates.Day(1):lastDate)
    dic = Dict(Pair.(df.Date_confirmation, df.Count_infected))
    infectedNew = [in.(dr[i], [Set(df.Date_confirmation)]) == Bool[1] ? dic[dr[i]] : 0 for i in 1:length(dr)]
    infectedTotal = [0]
    for i in 1:length(infectedNew)
        push!(infectedTotal, infectedTotal[i]+infectedNew[i])
    end
    infectedTotal = infectedTotal[2:end]
    dataSet = DataFrame(Date = dr,
                        New_infected = infectedNew,
                        Total_infected = infectedTotal
                    )
    return dataSet
end

function order(df)
    df = df |>
                 @orderby(_.Country) |>
    DataFrame
    select!(df, [:Country, :Date, :New_infected, :Total_infected])
    return df
end

worldData = timeSeries(df)
country = repeat(["World"], nrow(worldData))
worldData.Country = country
worldData = order(worldData)


gd = groupby(df, :Country)
countriesData = DataFrame()
for i in 1:length(gd)
    sd = timeSeries(gd[i])
    country = repeat([gd[i].Country[1]], nrow(sd))
    sd.Country = country
    append!(countriesData,sd)
end
countriesData = order(countriesData)

completeData = append!(worldData, countriesData)

vscodedisplay(completeData)

CSV.write("data/monkeypox_time_serie.csv", dataSet)
movingaverage(g, n) = [i < n ? mean(g[begin+n÷2:i+n÷2]) : mean(g[i+n÷2-n+1:i]) for i in 1+n÷2:length(g)];