cd(@__DIR__)
cd("..")
using Pkg; Pkg.activate("."); Pkg.instantiate()
using DataFrames, CSV
using Statistics: mean
using Queryverse
using Dates
using JSONTables


url = "https://raw.githubusercontent.com/globaldothealth/monkeypox/main/latest.csv"
download(url, "data/monkeypox_data.csv")


df = DataFrame(CSV.File("data/monkeypox_data.csv"))

df = df |>
    @filter(_.Status=="confirmed")|>
    @filter(!isna(_.Date_confirmation)) |>
    @orderby(_.Date_confirmation) |>
DataFrame
#Remplacer tous les noms des etats de la grande bretagne par United Kingdom
df[!,:Country][df[!,:Country] .== "England"] .= "United Kingdom"
df[!,:Country][df[!,:Country] .== "Wales"] .= "United Kingdom"
df[!,:Country][df[!,:Country] .== "Scotland"] .= "United Kingdom"
df[!,:Country][df[!,:Country] .== "Northern Ireland"] .= "United Kingdom"

function timeSeries(df)
    df= df |>
        @groupby(_.Date_confirmation) |>
        @orderby(_.Date_confirmation) |>
        @map({Date_confirmation=key(_), Count_infected=length(_)}) |>
    DataFrame
    firstDate = df.Date_confirmation[1]
    lastDate =  Dates.today() #Date d'aujourd'huui a la place
    dr = collect(firstDate:Dates.Day(1):lastDate)
    dic = Dict(Pair.(df.Date_confirmation, df.Count_infected))
    infectedNew = [in.(dr[i], [Set(df.Date_confirmation)]) == Bool[1] ? dic[dr[i]] : 0 for i in 1:length(dr)]
    infectedTotal = [0]
    for i in 1:length(infectedNew)
        push!(infectedTotal, infectedTotal[i]+infectedNew[i])
    end
    infectedTotal = infectedTotal[2:end]
    dataSet = DataFrame(Date_confirmation = dr,
                        New_infected = infectedNew,
                        Total_infected = infectedTotal
                    )
    return dataSet
end

function order(df)
    df = df |>
                 @orderby(_.Country) |>
    DataFrame
    select!(df, [:Country, :Date_confirmation, :New_infected, :Total_infected])
    return df
end

#Time series for all the whole world
worldData = timeSeries(df)
worldData.Country = repeat(["World"], nrow(worldData))
worldData = order(worldData)

#Time series for all the countries
gd = groupby(df, :Country)
countriesData = DataFrame()
for i in 1:length(gd)
    sd = timeSeries(gd[i])
    sd.Country = repeat([gd[i].Country[1]], nrow(sd))
    append!(countriesData,sd)
end
countriesData = order(countriesData)

#Time series complete
completeData = [worldData; countriesData]
#vscodedisplay(completeData)

#Generate and save file.csv
group = groupby(completeData, :Country)
CSV.write("data/global/monkeypox_time_series_$(group[1].Country[1]).csv", group[1])
for i in 2:length(group)
    CSV.write("data/by_country/monkeypox_time_series_$(group[i].Country[1]).csv", group[i])
end
CSV.write("monkeypox_time_series.csv", completeData)

todayList = DataFrame()
for i in 1:length(group)
    append!(todayList,DataFrame(last(group[i])))
    #todayList = [todayList; [group[i]]]
end
CSV.write("monkeypox_today.csv", todayList)
for i in 1:nrow(todayList)
    todayList.Index = repeat(i, nrow(todayList))
end
vscodedisplay(todayList)
j=objecttable(todayList)
open("foo.json","w") do f 
    write(f, j) 
end
