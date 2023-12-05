#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     EROSION Y DILATACION DE LA IMAGEN

using Images, ImageView, Gtk

estructura_1 = [1 1 1]

estructura_2 = [0 1 0;
                1 0 1;
                0 1 0]

estructura_3 = [0 1 0
                1 1 1;
                0 1 0]

estructura_4 = [1 0 0;
                1 1 1]

function makeImage2Binary(img)
    img_binary = zeros(size(img))
    threshold = 0.5

    for i in eachindex(img)
        (img[i] > threshold) ? (img_binary[i] = 1) : (img_binary[i] = 0)
    end

    return img_binary
end

function dilatacion(imagen::AbstractArray, elemento_estructurante::AbstractArray)
    filas, columnas = size(imagen) # tamaño de la imagen
    filas_ee, columnas_ee = size(elemento_estructurante)
    
    imagen_dilatada = zeros(filas,columnas)

    for i in 1:filas
        for j in 1:columnas
            if imagen[i, j] == 1
                for m in 1:filas_ee
                    for n in 1:columnas_ee
                        if i + m - 1 <= filas && j + n - 1 <= columnas && elemento_estructurante[m, n] == 1
                            imagen_dilatada[i + m - 1, j + n - 1] = 1
                        end
                    end
                end
            end
        end
    end

    return imagen_dilatada
end

function erosion(imagen::AbstractArray, elemento_estructurante::AbstractArray)
    filas, columnas = size(imagen)
    filas_ee, columnas_ee = size(elemento_estructurante)

    presencia = zeros(Int, filas, columnas)

    for i in 1:filas
        for j in 1:columnas
            presente = 1
            for m in 1:filas_ee
                for n in 1:columnas_ee
                    if i + m - 1 <= filas && j + n - 1 <= columnas
                        presente *= imagen[i + m - 1, j + n - 1] == elemento_estructurante[m, n]
                    else
                        presente *= 0
                    end
                end
            end
            presencia[i, j] = presente
        end
    end

    return presencia
end

# function erosion_2(imagen, estructura)
#     filas, columnas = size(imagen)
#     estFilas, estColumnas = size(estructura)
    
#     imagenFinal = zeros(Int, filas, columnas)

#     for i = 1:filas - estFilas + 1
#         for j = 1:columnas - estColumnas + 1
#             submatriz = imagen[i:i+estFilas-1, j:j+estColumnas-1]
#             comparacion = @.xor(submatriz, estructura)
#             if sum(comparacion) == 0
#                 imagenFinal[i+div(estFilas,2), j+div(estColumnas,2)] = 1
#             else
#                 imagenFinal[i+div(estFilas,2), j+div(estColumnas,2)] = 0
#             end
#         end
#     end

#     return imagenFinal
# end

function main()
    while true
        println("Selecciona la operacion a realizar: ")
        println("1.- Dilatacion")
        println("2.- Erosion")
        println("3.- Salir del programa")
        input = parse(Int, readline(stdin))

        if input == 1
            path = open_dialog("Pick a file")
            img_rgb = imresize(load(path), (256, 256))
            img = Gray.(copy(img_rgb))
            bin = makeImage2Binary(img)
            d1 = dilatacion(bin, estructura_1)
            d2 = dilatacion(bin, estructura_2)
            d3 = dilatacion(bin, estructura_3) 
            d4 = dilatacion(bin, estructura_4)

            imshow(mosaicview(img_rgb, Gray.(d1), Gray.(d2), Gray.(d3), Gray.(d4); nrow=1), name="Dilatacion")
        elseif input == 2
            path = open_dialog("Pick a file")
            img_rgb = imresize(load(path), (256, 256))
            img = Gray.(copy(img_rgb))
            bin = makeImage2Binary(img)

            e1 = erosion(bin, estructura_1)
            e2 = erosion(bin, hcat(estructura_1,estructura_1))
            e3 = erosion(bin, estructura_1[1,1:2]') 
            e4 = erosion(bin, hcat(estructura_1, estructura_1[1,1]))

            imshow(mosaicview(img_rgb, Gray.(e1), Gray.(e2), Gray.(e3), Gray.(e4); nrow=1), name="Erosion")
        elseif  input == 3
            break
        else 
            println("Selecciona una opcion valida")
        end
    end
end