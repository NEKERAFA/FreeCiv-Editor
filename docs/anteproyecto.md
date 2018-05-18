# Título
* Castellano: Generación de Escenarios de un Videojuego 2D mediante Programación Lógica
* Galego: Xeración de Escenarios de un Videoxogo 2D mediante Programación Lóxica
* English: Scenario Generation for a 2D Videogame using Logic Programming
# Titulación
Grado en Ingeniería Informática
# Objetivo
El objetivo final de este proyecto es la construcción de una herramienta declarativa para la creación y manipulación de escenarios o mapas para el videojuego FreeCiv, un juego de estrategia por turnos entre varios jugadores y que se desarrolla sobre un mapa tipo rejilla bidimensional. El propósito final es lograr, en la medida de lo posible, que la generación de escenarios sea gobernada por un conjunto de reglas, expresadas como restricciones en programación lógica, de modo que el usuario pueda variar sustancialmente la configuración de los escenarios obtenidos en función de la representación que haga del problema en términos de un programa lógico. Dada su adecuación para resolución de problemas, el paradigma de programación lógica que se usará es Answer Set Programming.
# Descripción
El proyecto consiste en el diseño e implementación de una herramienta para la creación y manipulación de entornos jugables para el videojuego FreeCiv (freeciv.org), un proyecto libre multiplataforma basado en la serie de videojuegos Sid Meier's: Civilization. La herramienta permitirá especificar reglas de construcción del escenario (por ejemplo, "no colocar un jugador entre dos montañas", "no colocar dos islas a menos de N casillas", etc) que pueden ser restricciones fuertes o, en su lugar, preferencias que se deben satisfacer en la medida de lo posible. De este modo, la generación del escenario estará gobernada total o parcialmente por reglas declarativas que permitirán al usuario definir distintos tipos de perfiles en función del propósito deseado o el nivel de dificultad esperado. Para codificar las reglas que definen el problema, se utilizará el paradigma de programación lógica conocido como Answer Set Programming (ASP) [1]. Este paradigma se ha convertido hoy en día en uno de los lenguajes de representación de conocimiento con mayor proyección y difusión debido tanto a su eficiencia en aplicación práctica para la resolución de problemas como a su flexibilidad y expresividad para la representación del conocimiento. La generación de escenarios de videojuegos supone un desafío como caso de prueba para ASP, ya que el número de combinaciones posibles aumenta exponencialmente en función del tamaño del escenario. El proyecto estudiará distintas técnicas para reducir esta explosión combinatoria manteniendo en la medida de lo posible, el carácter declarativo de la herramienta. Adicionalmente, se considerará la construcción de un pequeño editor gráfico que permita al usuario fijar manualmente algunas partes de la configuración del escenario, dejando que la herramienta complete las zonas no definidas.

[1] Gerhard Brewka, Thomas Eiter, and Mirosław Truszczyński. 2011. Answer set programming at a glance. Commun. ACM 54, 12 (December 2011), 92-103
# Departamento
Computación
# Material
Un ordenador. Una herramienta de resolución ASP (p.ej., el grupo de herramientas Potassco). Compiladores o intérpretes para los lenguajes de programación elegidos: para el generador de reglas o para el editor gráfico se considerarán distintas alternativas (p.ej. Lua y Moonscript) y el videojuego FreeCiv sobre el que se ejecutarán los ficheros generados para realizar las pruebas.
# Metodología
Para el desarrollo del proyecto se utilizará una metodología ágil aplicada de forma iterativa e incremental. Se tomará como referencia la metodología SCRUM, en especial en lo que se refiere a la gestión de la funcionalidad (agenda o "backlog" de producto, de sprint, gestión de tareas, etc) y de iteraciones, haciendo menos hincapié en la gestión del grupo de desarrollo, ya que el trabajo fin de grado es individual. Se usarán otras técnicas habituales en metodologías ágiles tales como la integración continua, el control de versiones o el desarrollo dirigido por pruebas.
# Fases
1. Estudio y análisis del estado del arte sobre la generación de escenarios en entornos similares, así como la investigación y estudio de la documentación del software elegido para el proyecto (en este caso FreeCiv).
2. Diseño e implementación del generador de entornos y módulo traductor ASP-FreeCiv.
3. Diseño de una herramienta para la manipulación de entornos en FreeCiv.
4. Evaluación de eficiencia para distintos casos de prueba.
