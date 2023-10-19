#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     PRACTICA 4 - TRAINING & TESTING

# Dada una imagen, crea clases a partir de la selección del usuario 
# y realiza la clasificación KNN basada en la distancia seleccionada.

using ImageView, Images, Statistics, PlotlyJS, DataFrames, StatisticalMeasures, LinearAlgebra
import Gtk4.open_dialog as dig

# Muestra una imagen I
mostrar(I) = return imshow(I, canvassize=(600, 600))
# Graficacion 
graficar(x,y,nombre,modo) = scatter(x=x, y=y, name=nombre, mode=modo)
graficar3D(x,y,z,nombre,modo) = scatter3d(
                                            x=x, y=y, z=z, 
                                            name=nombre, 
                                            mode=modo)
# Distancias
euclidean_distance(point1, point2) = sqrt(sum((point1 .- point2).^2))
mahalanobis_distance(x,m,mcov) = sqrt((x-m')*mcov*(x-m')')

# Seleccionar manualmente puntos en una imagen para formar clases.
# Genera una nube de representantes alrededor de estos puntos.
function class_selection(img, clases, clases_pos, n_clase, n_repre)
    s = mostrar(img);
    m,n = size(img) 
    show = true
    while show
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 

            if x != -1 && y != -1
                pixel_pos = Int(round(float(x))), Int(round(float(y)))
                push!(clases[n_clase], img[CartesianIndex(pixel_pos)])
                push!(clases_pos[n_clase], pixel_pos)
                ImageView.closeall()
                rr = 50
                cont = 0
                while cont < n_repre-1
                    new_repre = rand(-rr:rr)+pixel_pos[1], rand(-rr:rr)+pixel_pos[2]
                    if (new_repre[1]>0 && new_repre[1]<m) && (new_repre[2]>0 && new_repre[2]<n)
                        push!(clases[n_clase], img[CartesianIndex(new_repre)])
                        push!(clases_pos[n_clase], new_repre)
                        cont += 1
                    end
                end
                show = false
                return println("Process completed, please press ENTER to continue.")
            end
        end
        readline()
    end
end 

# Elegir una medida de distancia y realiza la clasificación de las clases basadas en la medida seleccionada.
function distance_menu(clases, covs, graf, img, nn)
    choice::Int64 = 0

    while choice != 3
        println("\nSelect a distance measure:")
        println("1. Euclidean Distance")
        println("2. Mahalanobis Distance")
        println("3. Quit")
        print("\nEnter your choice: ")
        choice = parse(Int, readline())

        if choice == 1
            println("You selected Euclidean Distance.")
            rand_pixel(length(clases), covs, graf, img, 0, nn, clases)
        elseif choice == 2
            println("You selected Mahalanobis Distance.")
            rand_pixel(length(clases), covs,graf, img, 1, nn, clases)
        elseif choice == 3
            println("Exiting the program.")
        else
            println("Invalid choice. Please select a valid option.")
        end
    end
end

# Permite al usuario seleccionar un píxel en la imagen y lo clasifica en una de las clases previamente definidas en función de la distancia de Mahalanobis. El resultado de la clasificación se muestra en un gráfico de dispersión 3D con el píxel desconocido y los representantes de las clases.
function rand_pixel(n_clases, covs, graf, img, modo, nn, clases) 
    s = mostrar(img);
    println("\n##############################")
    println("Select a pixel: ")
    println("##############################")

    while true
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            if x != -1 && y != -1
                #Evaluamos el pixel seleccionado y lo clasificamos
                pixel_pos = Int(round(float(x))), Int(round(float(y)))
                unknown = img[Int(round(float(x))), Int(round(float(y)))];
                vec_knn = [Array{Any}(undef, 0) for _ in 1:2]

                println("Pixel seleccionado correctamente")

                for i in 1:n_clases
                    if modo == 0
                        for j in eachindex(clases[i])
                            value = euclidean_distance( [Float64.(red.(unknown)) Float64.(green.(unknown)) Float64.(blue.(unknown))], [Float64.(red.(clases[i][j])) Float64.(green.(clases[i][j])) Float64.(blue.(clases[i][j]))])
                            push!(vec_knn[2], value)
                            push!(vec_knn[1], "Class $i")
                        end
                    else
                        for j in eachindex(clases[i])
                            value = mahalanobis_distance( [Float64.(red.(unknown)), Float64.(green.(unknown)), Float64.(blue.(unknown))]', [Float64.(red.(clases[i][j])), Float64.(green.(clases[i][j])), Float64.(blue.(clases[i][j]))], inv(reshape(covs[i], 3,3)))
                            push!(vec_knn[2], value)
                            push!(vec_knn[1], "Class $i")
                        end
                    end
                end

                data = DataFrame(
                    Class = vec_knn[1],
                    distance = vec_knn[2]
                )

                sorted_data = sort(data, :distance)
                # Extract the first nn
                first_nn = sorted_data[1:nn, :]
                # Find the most frequently occurring value in the specified column
                sorted_data = sort(combine(groupby(first_nn, [:Class]), nrow => :count), :count, rev=true)
                
                println("\n#####################################")
                println("El pixel seleccionado Pertence a la clase:")
                println(sorted_data[1, :Class])
                println("#####################################")
                println(sorted_data)
                println("#####################################\n")

                graf[n_clases+1] = graficar3D([round.((Float64.(red.(unknown))), digits=3)], [round.((Float64.(green.(unknown))), digits=3)], [round.((Float64.(blue.(unknown))), digits=3)], "Unknown", "markers")
                l = Layout(title="Scatter Plot")
                display(plot(graf, l))
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

function main()
    # Seleccion de imagen
    path::String = dig("Pick a File"; start_folder = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/img")
    img = load(path)

    # Numero de clases, representantes x clase y vecinos
    println("Ingresa el numero de clases: ");
    cInput::Int64 = parse(Int64, readline(stdin))
    println("Ingresa el numero de representantes: ");
    rInput::Int64 = parse(Int64, readline(stdin))
    println("Ingresa el numero de vecinos a considerar: ");
    nInput::Int64 = parse(Int64, readline(stdin))

    clases = [Array{RGB{N0f8}}(undef, 0) for _ in 1:cInput]
    clases_pos = [Array{Tuple{Int64, Int64}}(undef, 0) for _ in 1:cInput]
    graf = Vector{GenericTrace{Dict{Symbol, Any}}}(undef, cInput)
    grafRGB = Vector{GenericTrace{Dict{Symbol, Any}}}(undef, cInput+1)
    covs = Vector{Vector{Float64}}(undef, cInput)

    # Class generation
    for i in 1:cInput
        println("Select class $i: ")
        class_selection(img, clases, clases_pos, i, rInput)
        graf[i] = graficar( [clases_pos[i][j][1] for j in eachindex(clases_pos[i])],
                            [clases_pos[i][j][2] for j in eachindex(clases_pos[i])],
                            "Class $i", "markers")
        covs[i] = vec(
                cov([Float64.(red.(clases[i])) Float64.(green.(clases[i])) Float64.(blue.(clases[i]))], corrected=false))

        trace = graficar3D(round.(Float64.(red.(clases[i])), digits=3), round.((Float64.(green.(clases[i]))), digits=3), round.((Float64.(blue.(clases[i]))), digits=3), "Class $i", "markers")
        grafRGB[i]= trace
    end

    l = Layout(title="Classes")
    display(plot(graf, l))

    distance_menu(clases, covs, grafRGB, img, nInput)
end

