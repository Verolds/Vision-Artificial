#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL

using Images, ImageMorphology, DataFrames, CSV, PlotlyJS, StatsBase
using ScikitLearn
@sk_import cluster: AgglomerativeClustering
import Gtk4.open_dialog as dig

include("knn.jl")

function get_all_properties(path)
    features_path = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/Parcial2/features.csv"
    
    open(features_path, "w") do g
        println(g, "Area-Perim-nObjt-File")
    end

    for (i, file) in enumerate(readdir(path))
        filename = "$(path)/$file"
        img = Gray.(imresize(load(filename), (256, 256)))
        img_binary = Gray.(img .> .5)
        label = label_components(img_binary, strel_box((3, 3)))
        boxes = component_boxes(label)
        area = component_lengths(label)
        #index = component_indices(label)
    
        for j in eachindex(boxes[1:end])
            bounding_box_x, bounding_box_y = size(img_binary[boxes[j]])
            perim = bounding_box_x*2 + bounding_box_y*2
            open(features_path, "a") do g
                println(g, "$(area[j])-$perim-$(length(area)-1)-$filename")
                #println(g, "$(area[j])-$perim-$(index[j])-$filename")
            end
        end
    end 

    return features_path
end

function get_img_properties(img)
    areas = []
    perims = []
    rects = []

    label = label_components(img, strel_box((3, 3)))
    boxes = component_boxes(label)
    area = component_lengths(label)
    indices = component_indices(label)

    for j in eachindex(boxes[1:end])
        bounding_box_x, bounding_box_y = size(img[boxes[j]])
        perim = bounding_box_x*2 + bounding_box_y*2
        push!(areas, area[j])
        push!(perims, perim)
        push!(rects, indices[j])
    end

    return areas, perims, rects

end

function similar_imgs(dataset, contador, img)
    # AGRUPAR POR CLASES
    data = groupby(dataset, :class)
    img_same = []
    first = false
    # NUMERO TOTAL DE OBJETOS EN LA IMAGEN
    nn = sum(contador)
    #classes con 0 objetos
    indices = []
    for j in eachindex(contador)
        if contador[j] == 0
            push!(indices, j)
        end
    end

    # ITERAMOS PARA CADA CLASE
    for i in eachindex(contador)
        # DATOS DE LA CLASE 1
        dt = data[i]
        # NUMERO DE OBJETOS DE LA CLASE 1
        n = contador[i]
        # CONTAMOS EL NUMERO DE OBJETOS DE LA CLASE I AGRUPANDOLOS POR EL NOMBRE DEL ARCHIVO
        aux1 = combine(groupby(dt, [:File, :nObjt]), nrow => :count)
        # SI HAY OBJETOS DE LA CLASE I BUSCAMOS SIMILARES
        if n != 0
            if n == sum(contador)
                aux = aux1[(aux1.count .== aux1.nObjt), :]
                file = aux[:, :File]
                for gg in file
                    push!(img_same, gg)
                end
            else
                file = aux1[(n-3 .<= aux1.count .<= n+3 ) .& (nn-3 .< aux1.nObjt .< nn+3 ), :File ]
                for gg in file
                    if length(indices) != 0
                        for ind in indices
                            mal = data[ind]
                            mal2 = mal[findall(==(gg), mal.File), :]
                            #mal2 = filter(:File => ==(gg), mal)
                            if isempty(mal2)
                                #imshow(load.(gg))
                                push!(img_same, gg)
                            end
                        end
                    end
                end
                first = true
            end
        end
    end
    # VALORES UNICOS Y CON MAYOR REPETICION
    return_img = sort(countmap(img_same))
    idx = 0
    #rrss = []
    # RMOSTRAMOS SOLO LAS PRIMERAS 3 
    if first == true
        imshow(img; name="Similar 111")
    end
        
    if length(return_img) > 0
        for (image, v) in return_img
            idx += 1
            imshow(load(image); name="Similar")
            #push!(rrss, image)
            (idx==3) ? break : continue
        end
    else 
        println("Sin SIMILARES")
    end
    #return rrss
end

function main()

    examples_path = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/Parcial2/Imagenes/";
    # Lee toda la base de datos y regresa un CSV con el area, perimetro, numero de objetos y nombre del archivo
    features = get_all_properties(examples_path)
    # Leemos el CSV creado como DataFrame
    dataset = CSV.read(features, DataFrame, delim="-");
    # Tratamiento de datos y outliers 
    dataset = deleteat!(dataset, findall((dataset.Area .< 25) .&& (dataset.Perim .< 25)))
    # Dividimos en los datos que nos interesa aplicar el clustering (Area y perimetro)
    x = Matrix{Float64}(select(dataset, 1:2))
    # Aplicamos el clustering herarquico
    hc = AgglomerativeClustering(n_clusters=5, metric="euclidean", linkage="ward")
    #dataset = clustering(dataset, x, hc)
    y_hc = hc.fit_predict(x)
    # Agregamos al dataset la clase
    dataset.class = y_hc
    # sort(dataset, [:class])
    
    # 0->Blue     1->Green      2->Red        3->Yellow     4->Pink
    colors = [RGB{N0f8}(0, 0, 1.0), RGB{N0f8}(0, 1.0, 0), RGB{N0f8}(1.0, 0, 0), RGB{N0f8}(1.0, 1.0, 0.0), RGB{N0f8}(1.0, 0, 1.0)]
    # Ploteamos los clusters creados
    trace1 =scatter(x = x[y_hc.==0, 1], y = x[y_hc.==0, 2], marker_color=colors[1], mode = "markers", name="Cola de pato")
    trace2 =scatter(x = x[y_hc.==1, 1], y = x[y_hc.==1, 2], marker_color=colors[2],  mode = "markers", name = "Tornillos")
    trace3 =scatter(x = x[y_hc.==2, 1], y = x[y_hc.==2, 2], marker_color=colors[3],  mode = "markers", name = "Rondanas")
    trace4 =scatter(x = x[y_hc.==3, 1], y = x[y_hc.==3, 2], marker_color=colors[4],  mode ="markers", name = "Ganchos")
    trace5=scatter(x = x[y_hc.==4, 1], y = x[y_hc.==4, 2], marker_color=colors[5],  mode="markers", name="Palitos")

    # Diccionario de classes
    classes = Dict("0" => hcat(x[y_hc.==0, 1], x[y_hc.==0, 2])', 
                "1" => hcat(x[y_hc.==1, 1], x[y_hc.==1, 2])', 
                "2" => hcat(x[y_hc.==2, 1], x[y_hc.==2, 2])', 
                "3" => hcat(x[y_hc.==3, 1], x[y_hc.==3, 2])', 
                "4" => hcat(x[y_hc.==4, 1], x[y_hc.==4, 2])')

    while true
        # Leemos imagen de prueba
        path::String = dig("Pick a File"; start_folder = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/Parcial2/Imagenes/")
        img_rgb = imresize(load(path), (256, 256))
        img = Gray.(copy(img_rgb))
        bin = Gray.(img .> .5)

        # Obtenemos sus componentes 
        areas, perimiters, rects = get_img_properties(bin)
        # Organizamos los componentes de la imagen en un solo vector
        feature2know = hcat(areas, perimiters)'
        # Ploteamos los nuevos objetos
        trace6 = scatter(x = feature2know[1,:], y = feature2know[2, :], marker_color=:purple, mode="markers", name="Unknown")

        k = 5
        index = 1
        contador = [0, 0, 0, 0, 0]
        # KNN, coloreado de objetos y contador de objetos
        for point in eachcol(feature2know) 
            predicted_class = predict_using_knn(k, classes, point)

            if predicted_class == "0"
                contador[1] += 1
            elseif predicted_class == "1"
                    contador[2] += 1
            elseif predicted_class == "2"
                    contador[3] += 1
            elseif predicted_class == "3"
                    contador[4] += 1
            elseif predicted_class == "4"
                    contador[5] += 1
            end

            for j in rects[index] 
                img_rgb[j] = colors[parse(Int, predicted_class)+1]
            end 
            index += 1
        end
        # NUMERO DE OBJETOS DE CADA CLASE
        if sum(contador) > 35
            println("IMAGEN NO ACEPTADA")
            imshow(img)
        else
            display(plot([trace1, trace2, trace3, trace4, trace5, trace6]))
            println("Cola de pato : $(contador[1]) || Tornillos : $(contador[2]) || Rondanas : $(contador[3]) || Ganchos : $(contador[4]) || Palitos : $(contador[5])")
            # MOSTRAMOS EL PROCRESO DE CLASIFICACION
            imshow(mosaicview(img, Gray.(bin), img_rgb; nrow=1); name="Clasificador")
            similar_imgs(dataset, contador, img)
        end

        println("\n\nSi deseas salir del programas ingresa 'q' ");
        input = readline(stdin);
        (input == "q") ? break : continue
    end
end

# function similar_imgs_class(dataset, contador)
#     # AGRUPAR POR CLASES
#     data = groupby(dataset, :class)
#     img_same = []
#     # NUMERO TOTAL DE OBJETOS EN LA IMAGEN
#     nn = sum(contador)
#     # ITERAMOS PARA CADA CLASE
#     for i in eachindex(contador)
#         # DATOS DE LA CLASE 1
#         dt = data[i]
#         # NUMERO DE OBJETOS DE LA CLASE 1
#         n = contador[i]
#         # CONTAMOS EL NUMERO DE OBJETOS DE LA CLASE I AGRUPANDOLOS POR EL NOMBRE DEL ARCHIVO
#         aux = combine(groupby(dt, [:File, :nObjt]), nrow => :count)
#         # SI HAY OBJETOS DE LA CLASE I BUSCAMOS SIMILARES
#         if n != 0
#             # BUSCAMOS IMAGENES CON +-1 PRECISION DEL NUMERO DE OBJETOS DE LA CLASE I Y EL NUMERO TOTAL DE OBJETOS
#             #file = aux[(n-1 .<= aux.count .<= n+1 ) .& (nn-1 .<= aux.nObjt .<= nn+1 ), :File ]
#             file = aux[(aux.count .<= n) .& (aux.count .== aux.nObjt), :File ]
#             for gg in file
#                 push!(img_same, gg)
#             end
#         end
#     end
#     # VALORES UNICOS Y CON MAYOR REPETICION
#     return_img = sort(countmap(img_same))
#     idx = 0
#     #rrss = []
#     # RMOSTRAMOS SOLO LAS PRIMERAS 3 IMAGENES
#     if length(return_img) > 0
#         for (image, v) in return_img
#             idx += 1
#             imshow(load(image); name="Similar")
#             #push!(rrss, image)
#             (idx==4) ? break : continue
#         end
#     else 
#         println("No hay similares") 
#     end
#     #return rrss
# end


