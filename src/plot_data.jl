include("get_data.jl")
using Plots
using Statistics: mean
using Measures

#vscodedisplay(df)
gr()
theme(:dark)

function fig()
    fig = plot(foreground_color = :transparent,
                xrotation = 45,
                legend = false, 
                resolution = (1920,1080),
                ticks = :native,
                left_margin   =  2mm,
                right_margin	 =  2mm,
                top_margin	 =  0mm,
                bottom_margin =  3mm,
                yformatter = y -> round(Int64, y)
                )
end

#New Infected Graph
function graphNew(x,y1,date,y2)
    f = fig()
    bar!(date, y2,    
        alpha=0.8, 
        color="red",
        legend = :topleft,
        label = "New Cases"
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
function graphTotal(date,y3)
    f = fig()
    plot!(date,y3, 
        w=3, fill = (0, 0.05, :white), 
        legend = :topleft, 
        label = "Total Cases", 
        color="red",
        xrotation=45,
        yformatter = y -> round(Int64, y)
        )   
    return f    
end


#New Infected Animation
function animNew(x,y1,date,y2)
    fig()
    anim = @animate for i in 1:length(date) 
        
        if i ≤ length(x) && i > 1
            plot(x[1:i],y1[1:i], 
                w=3, fill = (0, 0.08, :white), 
                color="red",
                legend = false  
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
function animTotal(date,y3)
    fig()
    anim = @animate for i in 1:length(date)
            plot(date[1:i],y3[1:i],
                w=3, fill = (0, 0.05, :white), 
                legend = :topleft, 
                label = "Total Cases",
                color="red")
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
#group = groupby(completeData, :Country)
x, y1, date, y2, y3 = dataByGroup(group[1])
f1 = graphNew(x,y1,date,y2)
savefig(f1,"graphs/global/New_Infected_$(group[1].Country[1]).pdf")
savefig(f1,"graphs/global/New_Infected_$(group[1].Country[1]).png")
f2 = graphTotal(date,y3)
savefig(f2,"graphs/global/Total_Infected_$(group[1].Country[1]).pdf")
savefig(f2,"graphs/global/Total_Infected_$(group[1].Country[1]).png")
anim1 = animNew(x,y1,date,y2)
gif(anim1,"animations/global/NewCases_$(group[1].Country[1]).gif", fps=1)
anim2 = animTotal(date,y3)
gif(anim2,"animations/global/TotalCases_$(group[1].Country[1]).gif", fps=1)

#Gaphs and Animations for each Country
#for i  in 2:length(group)
#    x,y1,date,y2,y3 = dataByGroup(group[i])
#    f1 = graphNew(x,y1,date,y2)
#    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).pdf")
#    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).png")
#    f2 = graphTotal(date,y3)
#    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).pdf")
#    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).png")
#    anim1 = animNew(x,y1,date,y2)
#    gif(anim1,"animations/by_country/NewCases_$(group[i].Country[1]).gif", fps=1)
#    anim2 = animTotal(date,y3)
#    gif(anim2,"animations/by_country/TotalCases_$(group[i].Country[1]).gif", fps=1)
#end

#Provisory skip some country to avoid bug
for i in [2:12;16:26;29:31]
    x,y1,date,y2,y3 = dataByGroup(group[i])
    f1 = graphNew(x,y1,date,y2)
    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).pdf")
    savefig(f1,"graphs/by_country/New_Infected_$(group[i].Country[1]).png")
    f2 = graphTotal(date,y3)
    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).pdf")
    savefig(f2,"graphs/by_country/Total_Infected_$(group[i].Country[1]).png")
    anim1 = animNew(x,y1,date,y2)
    gif(anim1,"animations/by_country/NewCases_$(group[i].Country[1]).gif", fps=1)
    anim2 = animTotal(date,y3)
    gif(anim2,"animations/by_country/TotalCases_$(group[i].Country[1]).gif", fps=1)
    println(i)
end