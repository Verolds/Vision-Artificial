#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     PRACTICA 1 - PERTENECE AL CUBO 

using PlotlyJS, Statistics

# Mahalanobis x::vector desconocido, m::vector medias, mcov::matriz de covarianza 
distancia(x,m,mcov) = sqrt((x-m')*mcov*(x-m')')

graficar(x,y,z,color,nombre,modo) = scatter3d(
                                            x=x, y=y, z=z, 
                                            color=color, 
                                            name=nombre, 
                                            mode=modo)

                        
function main()
    #Cordenadas clase 1
    cords_c1 = [0 1 1 1;
                0 0 0 1;
                0 0 1 0]
    #Cordenadas clase 2
    cords_c2 = [0 0 1 0;
                0 1 1 1;
                1 1 1 0]
    
    mean1 = [mean(cords_c1[1,:])
            mean(cords_c1[2,:])
            mean(cords_c1[3,:])]

    mean2 = [mean(cords_c2[1,:])
            mean(cords_c2[2,:])
            mean(cords_c2[3,:])]

    cov1 = inv(cov([cords_c1[1,:] cords_c1[2,:] cords_c1[3,:]], corrected=false))
    cov2 = inv(cov([cords_c2[1,:] cords_c2[2,:] cords_c2[3,:]], corrected=false))

    layout = Layout(title="Scatter Plot")
    trace1 = graficar([cords_c1[1,:]; mean1[1]], [cords_c1[2,:]; mean1[2]], [cords_c1[3,:]; mean1[3]], :red3, "Class 1", "markers+lines")
    trace2 = graficar([cords_c2[1,:]; mean2[2]], [cords_c2[2,:]; mean2[2]], [cords_c2[3,:]; mean2[3]], :blue, "Class 2", "markers+lines" )

    while true
        println("Enter coordinates: x,y,z")
        punto = readline()
        p_cords = parse.(Float64, split(punto, ",", limit=3))'

        if 0≤p_cords[1]≤1 && 0≤p_cords[2]≤1 && 0≤p_cords[3]≤1
            
            d = Dict( "Clase 1" => distancia(p_cords, mean1, cov1), "Clase 2" => distancia(p_cords, mean2, cov2));
            min = minimum(values(d));
    
            for (k, v) = d
                if (v == min)
                    println("\n\nEl pixel seleccionado pertenece a la $k")
                    break
                end
            end 

            trace3 = graficar([p_cords[1]], [p_cords[2]], [p_cords[3]], :green, "Unknown", "markers")
            display(plot([trace1, trace2, trace3], layout))
        else
            println("El punto seleccionado se encuentra fuera del cubo")
        end

        println("\n\nSi deseas salir del programas ingresa 'q' ");
        input = readline(stdin);
        if input == "q"
            break
        end  
    end

end