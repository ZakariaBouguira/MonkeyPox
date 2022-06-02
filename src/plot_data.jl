include("get_data.jl")
using Plots
using Statistics: mean
using Measures

#vscodedisplay(df)

newInfected = worldData.New_infected
totalInfected = worldData.Total_infected
date = worldData.Date_confirmation

movingaverage(g, n) = [i < n ? mean(g[begin+n÷2:i+n÷2]) : mean(g[i+n÷2-n+1:i]) for i in 1+n÷2:length(g)]
y1 = movingaverage(newInfected, 7)
x = date[1:length(y1)]
y2 = newInfected
y3 = totalInfected

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
f1 = fig()
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
    savefig(f1,"graphs/New_Infected.pdf")
    savefig(f1,"graphs/New_Infected.png")

#Total Infected Graph
f2 = fig()
    plot!(date,y3, 
        w=3, fill = (0, 0.05, :white), 
        legend = :topleft, 
        label = "Total Cases", 
        color="red",
        xrotation=45,
        yformatter = y -> round(Int64, y))       
    savefig(f2,"graphs/Total_Infected.pdf")
    savefig(f2,"graphs/Total_Infected.png")

#New Infected Animation
function AnimNew()
    fig()
    animCases = @animate for i in 1:length(date) 
        if i ≤ length(x)
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

    gif(animCases,"animations/NewCases.gif", fps=1)
end
AnimNew()

#Total Infected Animation
function AnimTotal()
    fig()
    animCases = @animate for i in 4:length(date)
            plot(date[1:i],y3[1:i],
                w=3, fill = (0, 0.05, :white), 
                legend = :topleft, 
                label = "Total Cases",
                color="red")
    end

    gif(animCases,"animations/TotalCases.gif", fps=1)
end
AnimTotal()