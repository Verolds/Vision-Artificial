#     INSTITUTO POLITÉCNICO NACIONAL
#     ESCUELA SUPERIOR DE COMPUTO
#     VISION ARTIFICIAL
#     DETECCION DE BORDES

using ImageMorphology, Images, ImageView
import Gtk4.open_dialog as dig

function erosion(A, Ω)
    out = similar(A)
    Ω = CartesianIndex.(findall(Ω))
    R = CartesianIndices(A)
    for p in R
        Ωₚ = filter!(q->in(q, R), Ref(p) .+ Ω)
        out[p] = min(A[p], minimum(A[Ωₚ]))
    end
    return out
end
# Structuring Elements
Ω_mask1 = Bool[1 1 1; 1 1 0; 0 0 0] |> centered
Ω_mask2 = Bool[0 0 0; 0 1 1; 1 1 1] |> centered
Ω_mask3 = Bool[1 1 1; 1 1 1; 1 1 1] |> centered
Ω_mask4 = Bool[0 0 0; 1 1 1; 0 0 0] |> centered

function main()
    while true
        # Choose an image
        path = dig("Pick a File"; start_folder = "C:/Users/diego/OneDrive/Escritorio/ESCOM/5SEM/VA/Parcial2/Imagenes/")
        # Load image
        img = Gray.(imresize(load(path), (256, 256)))
        # Binarize image
        bin = @.Gray(img .> 0.5)
        # Erode image and get complement
        img_ec1 = .~(erosion(bin, Ω_mask1))
        img_ec2 = .~(erosion(bin, Ω_mask2))
        img_ec3 = .~(erosion(bin, Ω_mask3))
        img_ec4 = .~(erosion(bin, Ω_mask4))
        # AND between the binarize image and the output
        img_b1 = bin .== img_ec1
        img_b2 = bin .== img_ec2
        img_b3 = bin .== img_ec3
        img_b4 = bin .== img_ec4
        # Show output
        imshow(mosaicview(bin, img_b1, img_b2, img_b3, img_b4; nrow=1))

        println("\n\nSi deseas salir del programas ingresa 'q' ");
        input = readline(stdin);
        (input == "q") ? break : continue
    end
end