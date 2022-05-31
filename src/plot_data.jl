cd(@__DIR__)
cd("..")
using Pkg; Pkg.activate("."); Pkg.instantiate()

using Plots
using Measures

module GetData
include("get_data.jl")
export dataSet
export movingaverage
end

using .GetData
#vscodedisplay(df)

newInfected = dataSet.infectedNew
totalInfected = dataSet.infectedTotal
date = dataSet.date


y1 = movingaverage(newInfected, 7)
y2 = newInfected
y3 = totalInfected
x = dataSet.date[1:length(y1)]

gr()
theme(:dark)

function fig()
    fig = plot(foreground_color = :transparent,
                background = :transparent, 
                xrotation = 45,
                legend = false, 
                resolution = (1920,1080),
                ticks = :native,
                left_margin   =  2mm,
                right_margin	 =  12mm,
                top_margin	 =  0mm,
                bottom_margin =  3mm,
                yformatter = y -> round(Int64, y)
                )
end

f1 = fig()
    bar!(date, y2,    
        alpha=0.8, 
        color="red",
        legend = :topleft,
        label = "Count"
        )
    plot!(x,y1, 
        w=3, fill = (0, 0.5, :red), 
        color="red",
        legend = :topleft,
        label = "MA"
        )
    savefig(f1,"graphs/New_Infected.pdf")
    savefig(f1,"graphs/New_Infected.png")

f2 = fig()
    plot!(date,y3, 
        w=3, fill = (0, 0.05, :white), 
        legend = false, 
        color="red",
        xrotation=45,
        yformatter = y -> round(Int64, y))       
    savefig(f2,"graphs/Total_Infected.pdf")
    savefig(f2,"graphs/Total_Infected.png")

function AnimNew()
    fig()
    animCases = @animate for i in 1:length(date)
            if i ≤ length(x)
                plot(x[1:i],y1[1:i], 
                    w=3, fill = (0, 0.08, :blue), 
                    color="blue",
                    legend = false  
                    )
            end
            bar!(date[1:i],y2[1:i],
                alpha=0.8, color="blue",
                legend = false
                )   
            
    end

    gif(animCases,"animations/NewCases.gif", fps=1)
end
AnimNew()

function AnimTotal()
    fig()
    animCases = @animate for i in 4:length(date)
            plot(date[1:i],y3[1:i],
                w=3, fill = (0, 0.05, :white), 
                legend = false, 
                color="red")
    end

    gif(animCases,"animations/TotalCases.gif", fps=1)
end
AnimTotal()