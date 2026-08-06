# The Mice Plight — Game Design Document

## Género

El juego junta dos géneros: roguelike tradicional y deckbuilding

### Roguelike: Interpretación de Berlín

- **Muerte permanente.** Cuando tu personaje muere, se acabó. Empieza la partida de nuevo, desde el principio.
- **Generación procedural.** Los mapas, la colocación de objetos y los encuentros con enemigos se generan aleatoriamente en cada partida.
- **Juego por turnos.** El tiempo avanza sólo cuando realizas una acción.
- **Movimiento basado en cuadrículas.** Los personajes se mueven de una casilla a otra en una cuadrícula.
- **No modal.** Todo el juego se juega con un conjunto coherente de comandos, sin pantalla de combate separada.
- **Complejidad.** Los sistemas tienen profundidad, lo que permite un juego emergente.
- **Gestión de recursos.** No se puede conseguir todo en una sóla partida, se debe escoger.
- **Hack’n’slash.** El combate es el foco principal.
- **Exploración y descubrimiento.** Encontrar nuevas áreas y objetos es gratificante.

### Deckbuilding

- **Cartas.** Representan técnicas especiales de un personaje.
- **Baraja.** Es el conjunto total de cartas que tiene un personaje. Estas cartas no se pueden jugar. Se divide en:
	- **Pila de robo.** Las cartas que se roban para ir a la mano se obtienen de esta pila.
	- **Pila de descarte.** Las cartas que se descartan desde la mano van a esta pila. Cuando la pila de robo se queda sin cartas, la pila de descarte se baraja, y se coloca en la pila de robo.
- **Mano.** Es el subconjunto de cartas de la baraja que el personaje tiene acceso en un momento concreto. Las cartas en mano se pueden jugar.

## Temática

- **Ratón.** El único personaje controlado por el jugador.
- **Madriguera.** Es la comunidad de ratones bajo tierra, el hogar del personaje. Toda partida comienza en ella.
- **Depredadores.** Los enemigos son depredadores naturales de ratones. No son monstruos de fantasía. Extraídos de la zoología real. Su dieta debe incluir "pequeños mamíferos".
- **Naturaleza salvaje.** Los mapas son entornos naturales y salvajes, sin influencia humana.
- **Toque místico.** Referencias místicas, tales como: esencia natural, energía, magia leve. Eleva un poco las capacidades naturales de los animales.

## Loop del juego

1. **Inicio de la partida.** La partida inicia en la madriguera de los ratones.
2. **Madriguera.** El jugador escoge una clase de ratón de la madriguera.
3. **Zona de descanso inicial.** El ratón inicia a nivel de personaje 1. En este punto, el jugador puede realizar las mismas acciones disponibles en cualquier zona de descanso (ver paso 5), aunque en principio no tendrá recursos que gastar. Esto incluye elegir la recompensa del nivel 1.
4. **Primer bioma.** Es un mapa pequeño, con pocos enemigos.
5. **Zona de descanso.** El jugador puede realizar una o más de las siguientes acciones. Luego pasa al siguiente Bioma.
	- Recuperar la vida perdida.
	- Elegir la recompensa de este nivel.
	- Aprender nuevas cartas.
	- Añadir cartas a la baraja desde la lista de cartas aprendidas.
	- Quitar cartas de la baraja y ponerlas en la lista de cartas aprendidas.
	- Vincular o desvincular un trofeo imbuido.
	- Subir de nivel.
6. **Bioma.** Es un mapa mediano, con varios enemigos. Permite la exploración y recolección. Puede haber trampas. Hay un depredador élite que guarda la salida. La salida lleva a una zona de descanso, que luego llevará a otro bioma distinto, por un total de 5 veces. La zona de descanso tras el quinto bioma precede al jefe final.
7. **Jefe final.** Tras la zona de descanso posterior al quinto bioma, hay una zona pequeña donde reside el jefe final de la partida.
8. **Fin de la partida.** Si el ratón muere en cualquier paso anterior (3-7), la partida termina y se vuelve al paso 1 (muerte permanente). Si el ratón derrota al jefe final, la run es exitosa y se vuelve al paso 1 para iniciar una nueva partida.

## Tiradas d20

- Los dados añaden aleatoriedad al juego. Ayudan a determinar si los personajes tienen éxito en lo que intentan.
- Dados disponibles: **d4**, **d6**, **d8**, **d10**, **d12**, **d20**.
- Algunos efectos pueden otorgar **Ventaja** o **Desventaja** a las tiradas. En estos casos, se tiran 2 dados en vez de 1, y se utiliza el mayor o menor número, respectivamente.
- **Crítico y Pifia.**
	- **Tirada natural de 20 (Nat 20):** El ataque impacta automáticamente. El daño se calcula con el valor **máximo** de todos los dados de daño (e.g. 2d8+3 → 8+8+3 = 19).
	- **Tirada natural de 1 (Nat 1):** El ataque falla automáticamente, sin importar modificadores ni Dureza/Resistencia del objetivo.

## Efectos

[Listado de efectos](./effects/index.md)

- Son las capacidades de una carta, un ataque básico, una trampa o un peligro ambiental.
- Ejemplos: hacer daño, aplicar estado, empujar, saltar, entre muchos otros.
- Un efecto puede aplicar un estado a un personaje como parte de su resolución.
- Los efectos son instantáneos: ocurren y se resuelven en el mismo turno. Los estados, en cambio, persisten más allá del turno en que se aplican (ver Estados).

## Estados

[Lista de estados](./statuses/index.md)

- Se aplica a un personaje.
- Es temporal. Tiene una duración determinada.
- Cada estado reduce su duración en 1 al final del siguiente turno del personaje que contiene ese estado. De este modo, si es un beneficio, el personaje puede usarlo durante el turno en que lo tiene antes de que se reduzca. Si es un perjuicio, le afecta al menos un turno completo antes de poder caducar.
- Cuando su duración llega a 0, el estado es eliminado del personaje.
- Por defecto, los estados no se acumulan. Recibir un estado repetido reemplaza el anterior, incluyendo su duración. Estados individuales pueden definir reglas de acumulación distintas en su descripción.

## Personajes

### Familias

Cada personaje pertenece a uno de estos tipos de animales:

- **Aves.** Ejemplos: búho, halcón, águila.
- **Mamíferos.** Ejemplos: zorro, nutria, comadreja.
- **Herptiles.** Incluye anfibios y reptiles. Ejemplos: serpiente, sapo, salamandra.
- **Invertebrados.** Ejemplos: araña, escorpión, ciempiés.

### Atributo

Cada personaje dispone de estos atributos, con mayor o menor valor, en función de su naturaleza.

- **Fuerza (STR).** Poder físico.
- **Destreza (DEX).** Agilidad, reflejos y balance.
- **Constitución (CON).** Salud y resistencia.
- **Inteligencia (INT).** Razonamiento y memoria.
- **Sabiduría (WIS).** Perspicacia y fortaleza mental.
- **Carisma (CHA).** Confianza, aplomo y encanto.

### Pruebas de atributo

Representa a un personaje que usa su atributo para intentar superar un desafío.

- **Fuerza.** Levantar, empujar, tirar o romper algo.
- **Destreza.** Moverse con agilidad, rapidez o sigilo.
- **Constitución.** Llevar el cuerpo más allá de los límites normales.
- **Inteligencia.** Razonar o recordar.
- **Sabiduría.** Observar el entorno o el comportamiento de las criaturas.
- **Carisma.** Influir, entretener o engañar.

### Ataque

- Se puede realizar un ataque con un **Ataque básico** o jugando una **Carta**.
- Los ataques tienen una determinada precisión para impactar o afectar a un personaje.
- Cada ataque determina qué atributo utiliza para calcular efectividad.
- Hay dos tipos de ataque: **Físico** y **Especial**

#### Ataque físico

- El personaje atacado utiliza su **Dureza** para intentar anular el ataque.
- El personaje atacante utiliza un **Atributo** descrito en el ataque para incrementar sus posibilidades de éxito.
- `Impacta? = (tirada d20) + (modificador) >= (dureza personaje objetivo)`

#### Ataque especial

- El personaje atacado tira su propia tirada de resistencia para intentar resistir el ataque.
- Para resistir el ataque, debe utilizar el atributo de resistencia concreto indicado en el ataque (ver Resistencias).
- Cada ataque especial define su propio valor de **Resistencia**, un número que el defensor debe superar con su tirada.
- `¿Resiste? = (d20) + (modificador del atributo de resistencia) >= Resistencia del ataque`
- Si resiste: el daño se reduce a la mitad. Si el ataque aplicaba un estado, el estado no se aplica.

#### Cálculo del modificador

- `modificador = (atributo - 10)`. El atributo es el que el ataque (físico o especial) especifica.
- Ejemplos: atributo 10 → 0, atributo 14 → 4, atributo 20 → 10.

### Ataque básico

- Propio de un personaje, y representa su técnica de ataque común.
- No gasta ningún recurso, y está siempre disponible.
- Tiene un efecto más débil que el de una carta.
- El tipo de ataque es **Físico**, siempre.
- Tiene estos atributos:
	- **Alcance.** Determina la distancia a la que puede atacar.
	- **Area de efecto.** Determina qué casillas afecta, y cuantas.
	- **Efectos.** Determina qué hace el ataque. Puede realizar uno o más efectos.
	- **Escalado.** Puede escalar con uno o más atributos del personaje, modificando tanto el d20 de impacto como el daño posterior.

### Carta

[Listado de cartas](./cards/index.md)

- Propia de un personaje, y representan sus técnicas únicas.
- Tiene estos atributos:
	- **Coste de energía.** Debe pagarse para ser jugada.
	- **Alcance.** Determina la distancia a la que puede jugarse.
	- **Area de efecto.** Determina qué casillas afecta, y cuantas.
	- **Efectos.** Determina qué hace la carta. Puede realizar uno o más efectos.
	- **Escalado.** Puede escalar con uno o más atributos del personaje que la juega, dependiendo de la carta.
	- **Familia.** Indica a qué familia de animal pertenece. Algunas características y trofeos pueden afectar a cartas de una familia concreta; el efecto específico se define en cada trofeo o característica.
	- **Tipo.**
		- **Ataque.** Puede ser **Físico** o **Especial**. Si es Especial, debe indicar la resistencia requerida por el personaje atacado.
		- **Defensa.** Puede curar, dar puntos de vida temporales, etcétera.
		- **Especial.** Puede dar beneficios varios, invocar criaturas, etcétera.

### Dureza

- Afecta a la probabilidad de esquivar o anular un ataque de otro personaje o trampa.
- El valor normal es de 10, aunque puede variar entre 0 y 30.
- Cuanto más alta, más probabilidades de resistir el ataque.

### Resistencias

Los efectos causados por cartas o entorno pueden ser resistidos por algún atributo del personaje:

- **Fuerza.** Resistir físicamente la fuerza directa.
- **Destreza.** Esquivar el peligro.
- **Constitución.** Soportar un riesgo tóxico.
- **Inteligencia.** Reconocer una ilusión como falsa.
- **Sabiduría.** Resistir un ataque mental.
- **Carisma.** Afirmar la propia identidad.

### Daño

- Se usan dados para calcular el daño realizado por un ataque.
- El valor se describe en cada ataque.
- A los dados se les puede sumar o restar un número base. Por ejemplo: 3d8 + 5
- Notación por rango (configurable desde menú): en vez de 1d6 + 4, se puede decir [5 ~ 10]

### Puntos de vida

- Representan la resistencia y la voluntad de vivir. Si llegan a 0, el personaje **muere**.
- El valor no puede ser negativo.
- Escala con **Constitución**.
- Cuando un personaje tiene la mitad de Puntos de Vida o menos, está **Herido**. De por sí no hace nada, pero puede influir en otros efectos que lo indiquen.
- **TBD.** El valor concreto de los Puntos de Vida del ratón y de los depredadores está por determinar. Se balanceará en función del daño máximo posible de los ataques básicos y cartas, no al revés.

### Puntos de vida temporales

- Son adicionales a los puntos de vida del personaje.
- No pasa nada si se agotan.
- Por defecto, el valor es 0.
- El valor no puede ser negativo.
- Pueden ser otorgados por ciertas cartas u otros efectos.
- Sirven como protección contra la pérdida de los puntos de vida reales. Al recibir daño, estos puntos se pierden primero.
- Se pierden al llegar a una zona de descanso.
- No se acumulan. Siempre que se obtienen puntos de vida temporales, éstos sobreescriben a los que ya se tienen, si el número es mayor.

### Energía

- Recurso que lleva al personaje más allá de sus límites. Se consume para jugar cartas.
- Se recupera 1 de energía por turno.
- Fórmula del máximo: `base_clase + floor((INT - 10) / 2)`. El `base_clase` se define en cada clase, en `mice/index.md`.

### Iniciativa

- Determina el orden del turno para cada personaje que no sea el jugador.
- En cualquier caso, el jugador siempre va primero, y luego el resto de personajes, ordenados según su iniciativa.
- Se determina según la **Destreza** al instanciarse el bioma.
- Este valor no será visible al jugador, es un valor interno para ordenar los personajes no jugables.

### Acciones por Turno

Cada **acción** equivale a un **turno**. Cuando el jugador realiza una acción, el resto de elementos del juego toman su propio turno. Luego es el turno del jugador, y así constantemente. Las acciones disponibles para cualquier personaje son:
- **Mover.** 1 casilla, de forma ortogonal, no diagonal.
- **Ataque básico.** No es una carta. Siempre disponible. Inherente al personaje.
- **Jugar una carta.** Consume energía, según la carta.
- **Robar cartas.** Se descartan todas las cartas de la mano (incluidas las Cartas Ambientales), luego se roban cartas hasta llenar la mano. Consume 1 carga de recarga. Cada personaje empieza en el bioma con 3 cargas, y recupera una carga cada 5 turnos. Se pueden acumular hasta un máximo de 3 cargas.
- **Recolectar.** Recoger algo del suelo (semilla, carta ambiental, etc.). Disponible sólo para el jugador.
- **Saquear.** Recoger esencia y materiales del cadáver de un depredador. Solo disponible si el ratón está sobre un cadáver.
- **Esperar.** Consume el turno.


## Depredador

[Listado de depredadores](./predators/index.md)

Habitan en uno o más biomas, dependiendo de su naturaleza.

### Nivel de peligro

- Cada depredador tiene un nivel de peligro, determinado por su eficacia al cazar ratones, y de las probabilidades que tiene un ratón de sobrevivir a él.
- Este nivel es inmutable e inherente al depredador.
- Los niveles de peligro son:
	- **Alto.** Por ejemplo: Redhead Centipede, Giant Bullfrog.
	- **Muy Alto.** Por ejemplo: Green Horn, Goliath Frog.
	- **Letal.** Por ejemplo: Manul, Águila de cabeza blanca.
- En los primeros biomas de la partida se encuentran los depredadores de menos nivel de peligro, y se incrementa según se avanza en los siguientes biomas.
- Los atributos del depredador escalan en función de su nivel de peligro.

### Intención de depredador

- Todos los depredadores, al final de su turno, muestran su siguiente acción (intención), si es un **ataque básico** o **jugar una carta**. También muestran su intención de movimiento si se trata de un ataque con desplazamiento (carga, embestida). En estos casos, no pueden cambiar de acción ni de objetivo; atacarán, jugarán la carta o se desplazarán allá donde lo hayan anunciado.
- La intención se le revela al jugador mostrando las casillas que serán afectadas por la acción del depredador.
- Una animación especial mostrará que el depredador está preparado para lanzar un ataque o una carta.
- El jugador puede seleccionar el depredador para ver el detalle de qué ataque o carta ha preparado.

### Baraja del depredador

- Contiene 3 cartas únicas.
- Cada carta representa las capacidades del depredador.

### Mano del depredador

- Tamaño fijo de 3 cartas.
- Inicia la partida con 3 cartas en mano.

### Característica del depredador

- Cada depredador tiene una única característica.
- Una característica puede tener efectos diversos, tanto pasivos como reactivos. Puede alterar o amplificar los efectos de las cartas o ataques básicos, entre otras cosas.
- Es innata, fija para la especie. El ratón solo puede acceder a ella vinculando un trofeo crafteado con materiales de ese depredador.

### Cadáver de depredador

- Cuando un depredador muere, se convierte en un cadáver.
- Un cadáver ocupa una casilla, igual que un personaje vivo.
- Tiene una cantidad limitada de puntos de vida.
- Si los puntos de vida del cadáver llega a 0, éste es destruido, y desaparece.

## Ratón

### Clases de ratones

[Listado de clases de ratones](./mice/index.md)

Cada clase de ratón determina diferentes características:
- Cartas iniciales
- Atributos
- Ataque básico
- Mecánica única
- Recompensas por nivel.

### Baraja del ratón

- Empieza la partida con 12 cartas (las cartas iniciales de la clase).
- Puede llegar a un máximo de 16 cartas añadiendo cartas aprendidas durante la run.

### Mano del ratón

- Fórmula: `4 + floor((INT - 10) / 4)`.
- Ejemplos: INT 10 → 4, INT 14 → 5, INT 18 → 6, INT 20 → 6.

### Cartas memorizadas del ratón

- Durante la exploración de un bioma, el ratón **memoriza** las cartas utilizadas por los depredadores. 
- Estas cartas se añaden a un listado de **cartas memorizadas** que está disponible en la zona de descanso.
- Las cartas memorizadas se **olvidan** al entrar en un nuevo bioma, después de la zona de descanso.

### Cartas aprendidas del ratón

- En una zona de descanso, el ratón puede gastar **esencia** para **aprender** cartas memorizadas.
- Las cartas aprendidas se añaden al listado de **cartas aprendidas**. La cantidad de esencia a consumir dependen de cada carta.

### Esencia recolectada por el ratón

- La esencia se recolecta al saquear el cadáver de un depredador.
- La cantidad recolectada depende del depredador derrotado, de la **Sabiduría**, y del azar.

### Trofeos del ratón

- Al saquear el cadáver de un depredador, el ratón obtiene un **trofeo** del depredador (colmillo, pluma, garra, etc.). El trofeo lleva un resto de la esencia del depredador, pero está **inerte** tras su muerte.
- En las zonas de descanso, el ratón puede **imbuir** el trofeo con **esencia** (recogida de otros depredadores). Al imbuirlo, el trofeo pasa de **inerte** a **imbuido** y se vincula a un hueco.
- Un trofeo imbuido otorga al ratón la característica del depredador como pasiva.
- Imbuir un trofeo cuesta esencia. Vincular y desvincular trofeos imbuidos entre huecos es libre.
- Huecos: 3 iniciales. +1 en los niveles 3, 5 y 7. Máximo 7 huecos en nivel 8.
- Los trofeos inertes y los trofeos desvinculados se guardan en un alijo de la madriguera.

### Experiencia

- Un ratón puede obtener experiencia:
	- Al derrotar un depredador (no tiene que saquearlo).
	- En eventos

### Subir de nivel

- Un ratón puede obtener experiencia durante un bioma.
- En una zona de descanso puede subir de nivel si ha conseguido suficiente experiencia.
- La experiencia no se pierde entre biomas.
- Recompensas por nivel. El jugador elige 1 de las opciones disponibles para su clase. La matriz de elegibilidad se define en cada clase, en `mice/index.md`.
	- Características de ratón: pueden efectos diversos, tanto pasivos como reactivos.
	- Cartas Innatas: únicas para ratones
	- Puntos de atributo

## Biomas

### Tipos

- **Pantano.**
- **Tundra.**
- **Yermo.**
- **Bosque.**
- **Cañón.**

### Cartas Ambientales

- Cartas de **un solo uso** que solo funcionan dentro del bioma actual.
- Utilizables sólo por el ratón.
- Se recolectan durante la exploración del bioma.
- Cuando se recolectan, se añaden a la mano.
- No cuentan para el límite de mano.
- Desaparecen si se descartan, o al cambiar de bioma.
- Ejemplos:
	- Lanzar Piedra
	- Arrojar Fango
	- Consumir Planta

### Trampas

[Lista de trampas](./traps/index.md)

- Las trampas son elementos estáticos o móviles, dispersos por el bioma, que suponen un obstáculo o un peligro para el ratón.
- El contacto con una trampa hace que ésta se dispare y haga daño al ratón y/o le aplique algún estado negativo.
- Una trampa que se ha disparado queda desactivada y no se vuelve a reactivar.

### Peligros ambientales

[Lista de peligros ambientales](./hazards/index.md)

- Un peligro ambiental es un área que cubre una pequeña zona del mapa e impone un efecto negativo mientras se está en esa zona.
- Estas áreas pueden desplazarse lentamente.
- Afectan a todos los personajes en el área.
- Pueden imponer efectos tales como: reducir visibilidad, reducir un atributo (fuerza, destreza, etc.), etcétera.
- No hace daño.

### Recolección

- Recolectables consumibles esparcidos por el bioma (e.g. bayas en un arbusto, pequeños insectos, nidos con material, caparazones vacíos).
- Efectos menores: una baya cura 1-2 HP. No son moneda; ignorarlos no rompe la run.

### Eventos

[Lista de eventos](./events/index.md)

- Un evento es una situación no hostil.
- Los eventos están esparcidos por el bioma.
- El ratón puede interactuar con estos eventos para intentar obtener algún tipo de recompensa.
- El evento puede ofrecer una o varias pruebas de atributo para superarlo.
- Interactuar con el evento es opcional.
