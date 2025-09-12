

## **Reporte Semanal – Semana 3 (Fase 2)**

### **Objetivo de la semana**

El proposito de esta ultima semana fue finalizar la integracion completa del sistema asegurando que todos los modulos de hardware, backend y aplicacion movil funcionaran de manera conjunta. Además, se busco pulir los detalles esteticos y estructurales de la maqueta realizar pruebas completas de extremo a extremo y preparar la documentacion final junto con la evidencia necesaria para la entrega de la Fase 2.



### **Resumen general de avances**

Esta tercera semana represento la etapa de consolidacion del trabajo realizado en las dos anteriores los logros mas importantes fueron:

* **Finalizacion e integracion de las piezas 3D**
  Durante la reunion del dia miercoles se terminaron todas las piezas impresas en 3D  en la implementacion y montaje dentro de la maqueta asegurando que quedaran en las posiciones correctas y cumplieran con su funcion estructural y estetica.

* **Pruebas de extremo a extremo**
  Se valido el flujo completo de datos desde los sensores conectados al Arduino pasando por la Raspberry Pi y el broker MQTT hasta su registro en la base de datos mediante la API finalmente la informacion pudo ser consumida y visualizada en tiempo real en la aplicacion Flutter.

* **Optimizacion de la API y base de datos**
  Se realizaron ajustes en la estructura de la API para mejorar la eficiencia en las consultas ademas se optimizo la base de datos para reducir la latencia y garantizar la persistencia confiable de los eventos generados.

* **Aplicacion Flutter consolidada**
  Las tres vistas principales: Mapa Interactivo Feed de Notificaciones y Dashboard de Control quedaron conectadas a la API mostrando datos reales de los sensores y alertas generadas durante las pruebas.

* **Prototipo físico finalizado**
  La pieza 3D(postes y mercado) junto con los refuerzos esteticos y estructurales quedando integrada de forma definitiva en la maqueta esto permitio organizar mejor los componentes internos y mejorar la presentacion general del prototipo.

* **Documentacion y entrega final**
  Se recopilaron y organizaron los reportes semanales, los diagramas de arquitectura y flujo de datos así como la documentacion del Smart Connected Design Framework tambien se incluyo evidencia fotografica y se preparo el repositorio en GitHub con todo el codigo y la documentacion completa.

---

### **Aportes individuales**

#### **DANIEL ANDREE HERNANDEZ FLORES**

* Realizo las pruebas finales de comunicacion Arduino–Raspberry Pi–MQTT.
* Verifico la estabilidad del script de lectura del puerto serial y su publicacion en el broker.
* Integro definitivamente el modelo 3D en la maqueta


#### **EDUARDO SEBASTIAN GUTIERREZ FELIPE**

* Termino de integrar el Mapa Interactivo en Flutter con datos en tiempo real obtenidos de la API.
* Probo la actualizacion dinamica de la posicion simulada de transporte y verifico la correcta interaccion con la base de datos.
* Mantuvo la organizacion del repositorio y documento los avances de la app movil.

#### **ABDIEL FERNANDO JOSe OTZOY OTZÍN**

* Afino la API, corrigiendo errores en los endpoints y mejorando la validacion de datos.
* Aseguro la correcta comunicacion entre la API, la base de datos y Flutter.
* Genero reportes de pruebas de insercion y consulta de datos en tiempo real.

#### **GABRIEL ANDReS MELGAR ARAGoN**

* Culmino el Feed de Notificaciones en Flutter, mostrando alertas generadas por los sensores en la maqueta.
* Participo en pruebas conjuntas con el equipo de backend para validar la recepcion de alertas.
* Colaboro en el montaje final de la pieza 3D dentro de la maqueta.

#### **CHRISTIAN DAVID CHINCHILLA SANTOS**

* Documento los resultados de las pruebas de transmision de datos en tiempo real.
* Aseguro la correcta colocacion de los sensores y organizo el cableado interno.
* Superviso el estado del prototipo para la presentacion final.

#### **ENGEL EMILIO COC RAXJAL**

* Apoyo  en la implementacion y montaje de las piezas 3D terminadas durante la ultima reunion.
* Elaboro la documentacion final de la Fase 2 recopilando los aportes semanales.
* Coordino detalles esteticos y de presentacion en la maqueta para la entrega final.

#### **JHONATAN IVAN GUOZ TUBAC**

* Finalizo el Dashboard de Control en Flutter mostrando metricas de trafico y seguridad en tiempo real.
* Trabajo en la integracion de graficos dinámicos con los datos de la API.
* Colaboro en los ultimos ajustes esteticos de la maqueta.
* Termino de integrar el Mapa Interactivo en Flutter con datos en tiempo real obtenidos de la API.

#### **DANIEL ABRAHAM ORTIZ CHINCHILLA**

* Completo la documentacion del Smart Connected Design Framework incluyendo todas las capas y su aplicacion en la Fase 2.
* Termino los diagramas de flujo de datos y arquitectura final del sistema.
* Preparo material visual complementario para la entrega.

#### **BRYAN JOSUe CORONADO LAINEZ**

* Imprimio y diseño las piezas 3D
* Apoyo en el montaje final del prototipo físico y en la colocacion definitiva de la pieza 3D.
* Colaboro en la organizacion interna del prototipo asegurando la funcionalidad y estetica.



### **Dificultades encontradas**

* Durante la integracion de las piezas 3D fue necesario realizar varios ajustes en dimensiones y montaje, lo que alargo el tiempo de implementacion.
* Se presentaron problemas menores de sincronizacion entre la API y Flutter que fueron resueltos con ajustes en el formato de los datos.
* Algunos topicos MQTT presentaron perdida de mensajes en pruebas prolongadas, requiriendo configurar QoS más robusto.
* Al colocar las piezas 3D se hicieron perforaciones que provocaron desorden y que algunas piezas se despegaran por lo tanto fue necesario reajustarlas.

---

### **Tareas finales cumplidas para la entrega de Fase 2**

1. Entrega del prototipo fisico completamente integrado y funcional.
2. Montaje definitivo de todas las piezas 3D en la maqueta .
3. API conectada a la base de datos y consumida desde la app Flutter.
4. Flutter mostrando en tiempo real el mapa, el feed de notificaciones y el dashboard de control.
5. Documentacion final de los reportes semanales, diagramas y Smart Connected Design Framework.
6. Repositorio en GitHub actualizado con codigo, documentacion y diagramas.


--- 
### *Evidencia Fotografica:*