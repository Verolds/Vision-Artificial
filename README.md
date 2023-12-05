# Vision-Artificial
Practicas de Vision Artificial 

## Clasificador de Puntos en el Espacio Tridimensional : cubo_unitario_clase

Este programa permite clasificar puntos en el espacio tridimensional en dos clases definidas por las aristas de un cubo unitario. Utiliza la distancia de Mahalanobis para determinar a qué clase pertenece cada punto y genera una gráfica para visualizar los resultados.

### Requisitos

El programa ha sido desarrollado en Julia y utiliza las siguientes bibliotecas:

- Statistics
- PlotlyJS

### Uso

1. Selecciona un punto en el espacio tridimensional especificando sus coordenadas x, y, y z en el rango de 0 a 1.

2. El programa calculará la distancia de Mahalanobis entre el punto seleccionado y las dos clases definidas por las aristas del cubo unitario.

3. Clasificará el punto en la clase que tenga una distancia de Mahalanobis más cercana.

4. Se generará una gráfica que muestra el punto seleccionado y las dos clases en el espacio tridimensional.

5. El resultado de la clasificación se mostrará en la consola.

## Clasificador de Píxeles basado en Distancia de Mahalanobis RGB : mahalanobis_distance

Este programa permite la clasificación de píxeles en una imagen en función de las estadísticas de color de las clases previamente definidas. Utiliza la distancia de Mahalanobis en el espacio RGB para determinar a qué clase pertenece cada píxel. Además, genera gráficas de dispersión 3D para visualizar los resultados.

### Requisitos

El programa está desarrollado en Julia y utiliza las siguientes bibliotecas:

- ImageView
- Images
- Statistics
- PlotlyJS

### Uso

1. Selecciona el número de clases que deseas definir.

2. Selecciona el número de representantes por clase. Para cada clase, el programa te pedirá que selecciones píxeles representativos en la imagen.

3. Una vez que se hayan seleccionado los píxeles representativos, el programa calculará las estadísticas de color (medias y covarianzas) para cada clase y generará gráficas de dispersión 3D.

4. Luego, podrás seleccionar píxeles desconocidos en la imagen y el programa los clasificará en una de las clases definidas utilizando la distancia de Mahalanobis.

5. Los resultados de la clasificación se mostrarán en la consola y en una gráfica de dispersión 3D que incluye el píxel desconocido y los representantes de las clases.

## Clasificador Perceptrón para División de Clases : perceptron

Este programa implementa un clasificador de perceptrón para dividir dos clases en un espacio tridimensional utilizando una función lineal. El usuario puede ingresar los valores de los pesos iniciales, el término de sesgo (x0) y la tasa de aprendizaje (r) para entrenar el perceptrón y visualizar la división de clases en un espacio tridimensional.

### Requisitos

El programa está desarrollado en Julia y utiliza la biblioteca PlotlyJS para la visualización de datos.

### Uso

1. Ingresa los valores de los pesos iniciales (w1, w2, w3, w0), el término de sesgo (x0) y la tasa de aprendizaje (r) cuando se te solicite.

2. El programa entrenará el perceptrón y calculará los pesos finales. También generará un gráfico 3D que muestra la división de las clases en el espacio tridimensional.

3. Puedes ingresar nuevos valores de pesos y parámetros de aprendizaje para entrenar el perceptrón nuevamente y observar cómo cambia la división de las clases en el espacio.

## Clasificador de Píxeles basado en Distancia de Mahalanobis, euclideana o maxima probabilidad (RGB) : clasificacion_distancias

Este programa permite la clasificación de píxeles en una imagen en diferentes clases utilizando medidas de distancia y estadísticas de color. Permite al usuario seleccionar manualmente puntos en la imagen para formar clases y genera representantes alrededor de estos puntos. Luego, el programa permite clasificar nuevos píxeles en una de las clases utilizando tres medidas de distancia diferentes: Distancia Euclidiana, Distancia de Mahalanobis y Máxima Probabilidad.

### Requisitos 

El programa está desarrollado en Julia y utiliza las siguientes bibliotecas:

- ImageView
- Images
- Statistics
- PlotlyJS
- StatisticalMeasures
- LinearAlgebra

### Uso 

1. Ingresa el número de clases que deseas definir y el número de representantes que deseas generar alrededor de cada punto seleccionado para formar las clases.

2. Manualmente, selecciona puntos en la imagen haciendo clic en ellos. Cada punto seleccionado formará el centro de una clase y se generarán representantes alrededor de él.

3. Después de definir todas las clases, el programa mostrará un gráfico de dispersión con los puntos seleccionados y sus representantes alrededor de ellos.

4. Elige una medida de distancia:
   - 1 para Distancia Euclidiana.
   - 2 para Distancia de Mahalanobis.
   - 3 para Máxima Probabilidad.

5. El programa clasificará los píxeles de la imagen en función de la medida de distancia seleccionada y mostrará métricas de precisión, como la exactitud (accuracy) en diferentes escenarios.

## Clasificador KNN : main_knn

Este programa permite la seleccion de una imagen y su clasificación de píxeles en diferentes clases utilizando KNN (estadísticas de color). Permite al usuario seleccionar manualmente puntos en la imagen para formar clases y genera representantes alrededor de estos puntos. Luego, el programa permite clasificar nuevos píxeles en una de las clases.


## Detección de objetos : object_Detection
## Operaciones Morfologicas (erosion y dilatasion) : operaciones_morfologicas
## Detección de bordes : border_detection
