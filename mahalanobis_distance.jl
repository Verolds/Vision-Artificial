#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     PRACTICA 2 - PIXEL PERTENECE A ClASE
#     DISTANCIA DE MAHALANOBIS RGB 

# El programa generalmente se utiliza para la clasificación de píxeles en una imagen en función de las estadísticas de color de las clases definidas previamente. 
using ImageView, Images, Statistics, PlotlyJS, Distances

# Muestra una imagen I en una ventana utilizando la biblioteca ImageView. La imagen se muestra en un lienzo de tamaño 500x300 píxeles.
mostrar(I) = return imshow(I, canvassize=(500, 300))

distancia(x,m,mcov) = sqrt((x-m')*mcov*(x-m')')

# Crea un gráfico 3D de dispersión utilizando la biblioteca PlotlyJS. 
graficar(x,y,z,nombre,modo) = scatter3d(x=x, y=y, z=z, name=nombre, mode=modo)

# Permite al usuario seleccionar píxeles en una imagen. Los píxeles seleccionados se almacenan en la lista clases. La función solicita al usuario que seleccione n_representantes para la clase n_clase. Cuando se completa la selección, la ventana de visualización se cierra.
function seleccion(img, n_clase, n_representantes, clases)
    s = mostrar(img); 
    contador = 0;
    show=true
    while show
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            if x != -1 && y != -1
                    pixel = img[Int(round(float(x))), Int(round(float(y)))];
                    push!(clases[n_clase], pixel)
                    contador += 1;
                    println("\nValue $contador added")
                    if contador == n_representantes
                        ImageView.closeall()
                        show=false
                        return println("Process completed, please press ENTER to continue.")
                    end
            end
        end
        readline()
    end
end 

# Calcula las medias y las covarianzas de los canales de color (RGB) de los píxeles seleccionados en cada clase y crea gráficos de dispersión 3D para cada clase. Los resultados se almacenan en los arreglos means y covs, y los gráficos se almacenan en el arreglo graf.
function data_capture(means, arr, covs, graf)  
    
    for i in eachindex(arr)
        means[i] = [
            mean(Float64.(red.(arr[i])))
            mean(Float64.(green.(arr[i])))
            mean(Float64.(blue.(arr[i])))]
    end

    for i in eachindex(arr)
        covs[i] = vec(
                cov([Float64.(red.(arr[i])) Float64.(green.(arr[i])) Float64.(blue.(arr[i]))], corrected=false))
        trace = graficar([round.(Float64.(red.(arr[i])), digits=3); means[i][1]], [round.((Float64.(green.(arr[i]))), digits=3); means[i][2]], [round.((Float64.(blue.(arr[i]))), digits=3); means[i][3]], "Class $i", "markers")
        graf[i]= trace
    end 
end

# Permite al usuario seleccionar un píxel en la imagen y lo clasifica en una de las clases previamente definidas en función de la distancia de Mahalanobis. El resultado de la clasificación se muestra en un gráfico de dispersión 3D con el píxel desconocido y los representantes de las clases.
function rand_pixel(n_clases, means, covs, graf, img, arr) 
    s = mostrar(img);

    clases = [Array{Any}(undef, 0) for _ in 1:n_clases]
    for i in eachindex(clases)
        push!(clases[i], "Clase $i")
    end
    
    println("\n##############################")
    println("Select a pixel: ")
    println("##############################")
    while true
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            if x != -1 && y != -1
                #Evaluamos el pixel seleccionado y lo clasificamos
                unknown = img[Int(round(float(x))), Int(round(float(y)))];
                println("Pixel seleccionado correctamente")
                d = Dict()
                for i in 1:n_clases
                key = "Class $i"
                    # value = mahalanobis([Float64.(red.(unknown)), Float64.(green.(unknown)), Float64.(blue.(unknown))], means[i], 
                    # reshape(covs[i], 3,3))
                    value = distancia([Float64.(red.(unknown)), Float64.(green.(unknown)), Float64.(blue.(unknown))]', means[i], 
                    inv(reshape(covs[i], 3,3)))
                    get!(d, key, value)
                end

                m = minimum(values(d));

                graf[n_clases+1] = graficar([round.((Float64.(red.(unknown))), digits=3)], [round.((Float64.(green.(unknown))), digits=3)], [round.((Float64.(blue.(unknown))), digits=3)], "Unknown", "markers")
                l = Layout(title="Scatter Plot", xaxis_range=[0, 1], yaxis_range=[0,1], zaxis_range=[0,1])
                display(plot(graf, l))

                for (k, v) = d
                    if (v == m)
                        println("\n#####################################")
                        println("El pixel seleccionado con distancia $m")
                        print(d)
                        # if m>.009
                            # println("No pertenece a una clase")
                        # else
                            println("Pertence a la clase $k")
                        # end
                        println("#####################################\n")
                    end
                end 
            end
        end

        println("\n\nPress q to exit ");
        input = readline(stdin);
        if input == "q"
            ImageView.closeall()
            break
        end
    end
end

# El usuario selecciona el número de clases y el número de representantes por clase. Luego, se inicia el proceso de selección de píxeles para cada clase, seguido del cálculo de estadísticas y la clasificación de píxeles desconocidos.
function main()
    # Seleccion de imagen
    img = load("./VA/road.jpg");
    println("Ingresa el numero de clases: ");
    cInput = parse(Int64, readline(stdin))
    println("Ingresa el numero de representantes: ");
    rInput = parse(Int64, readline(stdin))

    arr = [Array{Any}(undef, 0) for _ in 1:cInput]
    means = [Array{Float64}(undef, 0) for _ in 1:cInput]
    covs = [Array{Float64}(undef, 0) for _ in 1:cInput]
    graf = Vector{GenericTrace{Dict{Symbol, Any}}}(undef, cInput+1)

    for i in 1:cInput
        println("Select class $i: ")
        seleccion(img, i, rInput, arr)
    end

    data_capture(means, arr, covs, graf)
    rand_pixel(cInput, means, covs, graf, img, arr) 

end
