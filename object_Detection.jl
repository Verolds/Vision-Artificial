#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     PRACTICA 1 - IDENTIFICACION DE OBJETOS

using Images, ImageView
import Gtk4.open_dialog as dig

function dfs(matrix, i, j, painted_image, color_objects)
    if i < 1 || i >= size(matrix, 1) || j < 1 || j >= size(matrix, 2)
        return
    end

    if matrix[i, j] == 0
        return
    end

    matrix[i, j] = 0
    painted_image[i, j] = color_objects

    dfs(matrix, i + 1, j, painted_image, color_objects)
    dfs(matrix, i - 1, j, painted_image, color_objects)
    dfs(matrix, i, j + 1, painted_image, color_objects)
    dfs(matrix, i, j - 1, painted_image, color_objects)

    # diagonalls
    dfs(matrix, i + 1, j + 1, painted_image, color_objects)
    dfs(matrix, i - 1, j + 1, painted_image, color_objects)
    dfs(matrix, i + 1, j - 1, painted_image, color_objects)
    dfs(matrix, i - 1, j - 1, painted_image, color_objects)

end

function main()
    path::String = dig("Pick a File"; start_folder = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/Parcial2/bd")
    
    img = load(path)
    img = imresize(img, (256, 256))

    painted_image = copy(img)
    img = Gray.(img)
    img_binary = zeros(size(img))
    m,n= size(img)

    threshold = 0.5 

    for i in eachindex(img)
        pixel = img[i]
        if pixel > threshold
            img_binary[i] = 1
        else
            img_binary[i] = 0
        end
    end

    num_objects = 0

    for i in 1:m
        for j in 1:n
            if img_binary[i, j] == 1
                num_objects += 1
                dfs(img_binary, i, j, painted_image, RGB(rand(3)...))
            end
        end
    end

    println("Number of objects: ", num_objects)
    display(painted_image)

    print("Sizez of the image: ", size(img_binary, 1), " ", size(img_binary, 2))
    print("sizes of the new img ", size(painted_image, 1), " ", size(painted_image, 2))
end
