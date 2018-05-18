project='FreeCiv Editor'
title='Generación de Escenarios de un Videojuego 2D mediante Programación Lógica'
full_description=[[#Generación de Escenarios de un Videojuego 2D mediante Programación Lógica.

El proyecto consiste en el diseño e implementación de una herramienta para la creación y manipulación de entornos jugables para el videojuego FreeCiv (freeciv.org), un proyecto libre multiplataforma basado en la serie de videojuegos Sid Meier's: Civilization. La herramienta permitirá especificar reglas de construcción del escenario (por ejemplo, "no colocar un jugador entre dos montañas", "no colocar dos islas a menos de N casillas", etc) que pueden ser restricciones fuertes o, en su lugar, preferencias que se deben satisfacer en la medida de lo posible. De este modo, la generación del escenario estará gobernada total o parcialmente por reglas declarativas que permitirán al usuario definir distintos tipos de perfiles en función del propósito deseado o el nivel de dificultad esperado. Para codificar las reglas que definen el problema, se utilizará el paradigma de programación lógica conocido como Answer Set Programming (ASP) [1]. Este paradigma se ha convertido hoy en día en uno de los lenguajes de representación de conocimiento con mayor proyección y difusión debido tanto a su eficiencia en aplicación práctica para la resolución de problemas como a su flexibilidad y expresividad para la representación del conocimiento. La generación de escenarios de videojuegos supone un desafío como caso de prueba para ASP, ya que el número de combinaciones posibles aumenta exponencialmente en función del tamaño del escenario. El proyecto estudiará distintas técnicas para reducir esta explosión combinatoria manteniendo en la medida de lo posible, el carácter declarativo de la herramienta. Adicionalmente, se considerará la construcción de un pequeño editor gráfico que permita al usuario fijar manualmente algunas partes de la configuración del escenario, dejando que la herramienta complete las zonas no definidas.

[1] Gerhard Brewka, Thomas Eiter, and Mirosław Truszczyński. 2011. Answer set programming at a glance. Commun. ACM 54, 12 (December 2011), 92-103]]
format='discount'
style='!pale'
file='./src/main'
dir='./docs/ldoc'
sort=true
