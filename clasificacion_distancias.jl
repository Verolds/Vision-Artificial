#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     PRACTICA 4 - TRAINING & TESTING

# Dada una imagen, crea clases a partir de la selección del usuario 
# y realiza la clasificación basada en la distancia seleccionada.


using ImageView, Images, Statistics, PlotlyJS, StatisticalMeasures, LinearAlgebra

# Muestra una imagen I
mostrar(I) = return imshow(I, canvassize=(600, 600))
# Graficacion 
graficar(x,y,nombre,modo) = scatter(x=x, y=y, name=nombre, mode=modo)
# Distancia euclidiana entre dos puntos.
euclidean_distance(point1, point2) = sqrt(sum((point1 .- point2).^2))
# Distancia de Mahalanobis entre un punto x y una clase.
mahalanobis_distance(x,m,mcov) = sqrt((x-m')*mcov*(x-m')')
# Máxima probabilidad entre un punto x, y una clase.
function max_prob_distance(x,m,mcov)
    dato1 =  ℯ^(-(mahalanobis_distance(x, m, inv(mcov))))
    dato2 = 1 / ((2*π^(3/2)) * det(mcov)^(-(1/2)))
    return dato1 * dato2
end
# Seleccionar manualmente puntos en una imagen para formar clases.
# Genera una nube de representantes alrededor de estos puntos.
function class_selection(img, clases, clases_pos, n_clase, n_repre)
    s = mostrar(img);
    m,n = size(img) 
    show=true
    while show
        map(s["gui"]["canvas"].mouse.buttonpress) do btn
            x = btn.position.y; 
            y = btn.position.x; 
            if x != -1 && y != -1
                    pixel_pos = Int(round(float(x))), Int(round(float(y)))
                    push!(clases[n_clase], img[CartesianIndex(pixel_pos)])
                    push!(clases_pos[n_clase], pixel_pos)
                    ImageView.closeall()
                    rr = 70
                    cont = 0
                    while cont < n_repre-1
                        new_repre = rand(-rr:rr)+pixel_pos[1], rand(-rr:rr)+pixel_pos[2]
                        if (new_repre[1]>0 && new_repre[1]<m) && (new_repre[2]>0 && new_repre[2]<n)
                            push!(clases[n_clase], img[CartesianIndex(new_repre)])
                            push!(clases_pos[n_clase], new_repre)
                            cont += 1
                        end
                    end

                    show=false
                    return println("Process completed, please press ENTER to continue.")
            end
        end
        readline()
    end
end 
# Elegir una medida de distancia y realiza la clasificación de las clases basadas en la medida seleccionada.
function distance_menu(clases, means, covs)
    choice = 0

    while choice != 4
        println("\nSelect a distance measure:")
        println("1. Euclidean Distance")
        println("2. Mahalanobis Distance")
        println("3. Maxima Probabilidad Distance")
        println("4. Quit")
        print("\nEnter your choice: ")
        choice = parse(Int, readline())

        if choice == 1
            println("You selected Euclidean Distance.")
            euclidean_classification(clases, means)
        elseif choice == 2
            println("You selected Mahalanobis Distance.")
            mahalanobis_classification(clases, means, covs)
        elseif choice == 3
            println("You selected _ Distance.")
            max_prob_classification(clases, means, covs)
        elseif choice == 4
            println("Exiting the program.")
        else
            println("Invalid choice. Please select a valid option.")
        end
    end
end
# Clasificación utilizando la distancia euclidiana y muestra métricas de precisión.
function euclidean_classification(clases, means)
    println("EUCLIDEAN")
    println("RESUST METOD")
    k =length(clases[1])
    resust_accuracy = euclidean_general(clases, means, k, 1) * 100
    
    println("CROSS VALIDATION METOD")
    cross_accuracy = []
    for _ in 1:20
        k = div(length(clases[1]), 2)
        push!(cross_accuracy, euclidean_general(clases, means, k, rand(1:k)) * 100)
    end
    aux = mean(cross_accuracy)

    println("LEAVE ONE OUT METOD")
    k = rand(1:length(clases[1]))
    one_out_accuracy = euclidean_general(clases, means, 1, k) * 100

    println("\n---------------------------------------")
    println("Resust Accuracy: $resust_accuracy %")
    println("Cross validation Accuracy: $aux%")
    println("Leave one out validation Accuracy: $one_out_accuracy%")
    println("---------------------------------------")
end
function euclidean_general(clases, means, n, start)
    true_labels = []
    predicted_labels = []
    data = []
    for i in eachindex(clases)
        n = n
        true_labels = vcat(true_labels, fill("C$i", n))
        start_index = start
        data = clases[i][start_index:(start_index + n - 1)]

        for val in data
            d = Dict()
            for i in eachindex(clases)
                key = "C$i"
                value = euclidean_distance( [Float64.(red.(val)) Float64.(green.(val)) Float64.(blue.(val))], means[i])
                get!(d, key, value)
            end

            m = minimum(values(d));

            for (k, v) = d
                if (v == m)
                    push!(predicted_labels, k)
                end
            end
        end
    end
    # Create a confusion matrix
    cm = confmat(predicted_labels, true_labels)
    display(cm)
    ac = sum(diag(ConfusionMatrices.matrix(cm)))/sum(ConfusionMatrices.matrix(cm))
    return ac
end
# Clasificación utilizando la distancia de Mahalanobis y muestra métricas de precisión.
function mahalanobis_classification(clases, means, covs)
    println("\nMAHALANOBIS")
    println("RESUST METOD")
    k =length(clases[1])
    resust_accuracy = mahalanobis_general(clases, means, covs, k, 1) * 100
    
    println("CROSS VALIDATION METOD")
    cross_accuracy = []
    for _ in 1:20
        k = div(length(clases[1]), 2)
        push!(cross_accuracy, mahalanobis_general(clases, means, covs, k, rand(1:k)) * 100)
    end
    aux = mean(cross_accuracy)

    println("LEAVE ONE OUT METOD")
    k = rand(1:length(clases[1]))
    one_out_accuracy = mahalanobis_general(clases, means, covs, 1, k) * 100

    println("\n---------------------------------------")
    println("Resust Accuracy: $resust_accuracy %")
    println("Cross validation Accuracy: $aux%")
    println("Leave one out validation Accuracy: $one_out_accuracy%")
    println("---------------------------------------")
end
function mahalanobis_general(clases, means, covs, n, start)
    true_labels = []
    predicted_labels = []
    data = []
    for i in eachindex(clases)
        n = n
        true_labels = vcat(true_labels, fill("C$i", n))
        start_index = start
        data = clases[i][start_index:(start_index + n - 1)]

        for val in data
            d = Dict()
            for i in eachindex(clases)
                key = "C$i"
                value =mahalanobis_distance([Float64.(red.(val)), Float64.(green.(val)), Float64.(blue.(val))]', means[i], 
                    inv(reshape(covs[i], 3,3)))
                get!(d, key, value)
            end

            m = minimum(values(d));

            for (k, v) = d
                if (v == m)
                    push!(predicted_labels, k)
                end
            end
        end
    end
    #cm = confmat(predicted_labels, true_labels)
    # Create a confusion matrix
    cm = confmat(predicted_labels, true_labels)
    display(cm)
    ac = sum(diag(ConfusionMatrices.matrix(cm)))/sum(ConfusionMatrices.matrix(cm))
    return ac
end
# Clasificación utilizando la medida de máxima probabilidad y muestra métricas de precisión.
function max_prob_classification(clases, means, covs)
    println("\nMAXIMA PROBABILIDAD")
    println("RESUST METOD")
    k =length(clases[1])
    resust_accuracy = max_prob_general(clases, means, covs, k, 1) * 100
    
    println("CROSS VALIDATION METOD")
    cross_accuracy = []
    for _ in 1:20
        k = div(length(clases[1]), 2)
        push!(cross_accuracy, max_prob_general(clases, means, covs, k, rand(1:k)) * 100)
    end
    aux = mean(cross_accuracy)

    println("LEAVE ONE OUT METOD")
    k = rand(1:length(clases[1]))
    one_out_accuracy = max_prob_general(clases, means, covs, 1, k) * 100

    println("\n---------------------------------------")
    println("Resust Accuracy: $resust_accuracy %")
    println("Cross validation Accuracy: $aux%")
    println("Leave one out validation Accuracy: $one_out_accuracy%")
    println("---------------------------------------")
end
function max_prob_general(clases, means, covs, n, start)
    true_labels = []
    predicted_labels = []
    data = []
    for i in eachindex(clases)
        n = n
        true_labels = vcat(true_labels, fill("C$i", n))
        start_index = start
        data = clases[i][start_index:(start_index + n - 1)]

        for val in data
            d = Dict()
            for i in eachindex(clases)
                key = "C$i"
                value =max_prob_distance([Float64.(red.(val)), Float64.(green.(val)), Float64.(blue.(val))]', means[i], 
                reshape(covs[i], 3,3))
                get!(d, key, value)
            end

            m = maximum(values(d));

            for (k, v) = d
                if (v == m)
                    push!(predicted_labels, k)
                end
            end
        end
    end
    #cm = confmat(predicted_labels, true_labels)
    # Create a confusion matrix
    cm = confmat(predicted_labels, true_labels)
    display(cm)
    ac = sum(diag(ConfusionMatrices.matrix(cm)))/sum(ConfusionMatrices.matrix(cm))
    return ac
end

function main()
    # Seleccion de imagen
    img = load("./VA/desert.jpg");
    m,n = size(img)
    # Numero de clases y representantes x clase
    println("Ingresa el numero de clases: ");
    cInput = parse(Int64, readline(stdin))
    println("Ingresa el numero de representantes: ");
    rInput = parse(Int64, readline(stdin))
    #cInput = 2 rInput = n_repre = 10

    clases = [Array{Any}(undef, 0) for _ in 1:cInput]
    clases_pos = [Array{Any}(undef, 0) for _ in 1:cInput]
    graf = Vector{GenericTrace{Dict{Symbol, Any}}}(undef, cInput)
    means = [Array{Float64}(undef, 0) for _ in 1:cInput]
    covs = [Array{Float64}(undef, 0) for _ in 1:cInput]

    
    # Class generation
    for i in 1:cInput
        println("Select class $i: ")
        class_selection(img, clases, clases_pos, i, rInput)
        graf[i] = graficar( [clases_pos[i][j][1] for j in eachindex(clases_pos[i])],
                            [clases_pos[i][j][2] for j in eachindex(clases_pos[i])],
                            "Class $i", "markers")
    end

    # Generate means
    for i in eachindex(clases)
        means[i] = [
            mean(Float64.(red.(clases[i])))
            mean(Float64.(green.(clases[i])))
            mean(Float64.(blue.(clases[i])))]

        covs[i] = vec(
                cov([Float64.(red.(clases[i])) Float64.(green.(clases[i])) Float64.(blue.(clases[i]))], corrected=false))
    end

    l = Layout(title="Scatter Plot Classes")
    display(plot(graf, l))

    distance_menu(clases, means, covs)
end