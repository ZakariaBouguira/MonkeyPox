include("get_data.jl")
using Plots
using Statistics: mean
using Measures
using LaTeXStrings
#vscodedisplay(df)
gr()
theme(:dark)

function fig()
    fig = plot(foreground_color = :transparent,
                xrotation = 45,
                legend = false, 
                resolution = (1920,1080),
                ticks = :native,
                left_margin   =  4mm,
                right_margin	 =  2mm,
                top_margin	 =  1mm,
                bottom_margin =  5mm,
                yformatter = y -> round(Int64, y)
                )
end

#New Infected Graph
function graphNew(x,y1,date,y2,countryName)
    f = fig()
    bar!(date, y2,    
        alpha=0.8, 
        color="red",
        legend = :topleft,
        label = "New Cases",
        title = "New Monkey Pox Cases In $countryName"
        )
    plot!(x,y1, 
        w=3, fill = (0, 0.05, :white), 
        color="red",
        legend = :topleft,
        label = "MA"
        )
    return f    
end


#Total Infected Graph
function graphTotal(date,y3,countryName)
    f = fig()
    plot!(date,y3, 
        w=3, fill = (0, 0.05, :white), 
        legend = :topleft, 
        label = "Total Cases", 
        color="red",
        xrotation=45,
        yformatter = y -> round(Int64, y),
        title = "Total Monkey Pox Cases In $countryName"
        )   
    return f    
end


#New Infected Animation
function animNew(x,y1,date,y2,countryName)
    fig()
    anim = @animate for i in 1:length(date) 
        
        if i ≤ length(x) && i > 1
            plot(x[1:i],y1[1:i], 
                w=3, fill = (0, 0.08, :white), 
                color="red",
                legend = false,
                title = "New Monkey Pox Cases In $countryName"          
                )
        end
        bar!(date[1:i],y2[1:i],
                alpha=0.8, color="red",
                legend = false
                )          
    end
    return anim
end


#Total Infected Animation
function animTotal(date,y3,countryName)
    fig()
    anim = @animate for i in 1:length(date)
            plot(date[1:i],y3[1:i],
                w=3, fill = (0, 0.05, :white), 
                legend = :topleft, 
                label = "Total Cases",
                color="red",
                title = "Total Monkey Pox Cases In $countryName")
    end
    return anim
end


movingaverage(g, n) = [i < n ? mean(g[begin+n÷2:i+n÷2]) : mean(g[i+n÷2-n+1:i]) for i in 1+n÷2:length(g)]

function dataByGroup(sd)
    newInfected = sd.New_infected
    totalInfected = sd.Total_infected
    date = sd.Date_confirmation

    y1 = length(newInfected)>=7 ? movingaverage(newInfected, 7) : 0
    x = date[1:length(y1)]
    y2 = newInfected
    y3 = totalInfected
    return x, y1, date, y2, y3
end

#World Graphs and Animations
#(group = groupby(completeData, :Country) from get_data.jl
x, y1, date, y2, y3 = dataByGroup(group[1])
countryName = "The "*group[1].Country[1]
f1 = graphNew(x,y1,date,y2,countryName)
savefig(f1,"graphs/global/New_Infected_$(group[1].Country[1]).pdf")
savefig(f1,"graphs/global/New_Infected_$(group[1].Country[1]).png")
f2 = graphTotal(date,y3,countryName)
savefig(f2,"graphs/global/Total_Infected_$(group[1].Country[1]).pdf")
savefig(f2,"graphs/global/Total_Infected_$(group[1].Country[1]).png")
anim1 = animNew(x,y1,date,y2,countryName)
gif(anim1,"animations/global/NewCases_$(group[1].Country[1]).gif", fps=1)
anim2 = animTotal(date,y3,countryName)
gif(anim2,"animations/global/TotalCases_$(group[1].Country[1]).gif", fps=1)

#Gaphs and Animations for each Country
j=0
#for i  in 2:length(group)
    #j=i
    #x,y1,date,y2,y3 = dataByGroup(group[i])
    #countryName = group[i].Country[1]
    #f1 = graphNew(x,y1,date,y2,countryName)
    #savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).pdf")
    #savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).png")
    #f2 = graphTotal(date,y3,countryName)
    #savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).pdf")
    #savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).png")
    #anim1 = animNew(x,y1,date,y2,countryName)
    #gif(anim1,"animations/by_country/NewCases_$(group[i].Country[1]).gif", fps=1)
    #anim2 = animTotal(date,y3,countryName)
    #gif(anim2,"animations/by_country/TotalCases_$(group[i].Country[1]).gif", fps=1)

#end
println(j)
#Provisory skip some country to avoid bug
for i in [2:18;20:length(group)]
    j=i
    x,y1,date,y2,y3 = dataByGroup(group[i])
    countryName = group[i].Country[1]
    f1 = graphNew(x,y1,date,y2,countryName)
    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).pdf")
    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).png")
    f2 = graphTotal(date,y3,countryName)
    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).pdf")
    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).png")
    anim1 = animNew(x,y1,date,y2,countryName)
    gif(anim1,"animations/by_country/NewCases_$(group[i].Country[1]).gif", fps=1)
    anim2 = animTotal(date,y3,countryName)
    gif(anim2,"animations/by_country/TotalCases_$(group[i].Country[1]).gif", fps=1)
    println(j)
end