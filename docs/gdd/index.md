# The Mice Plight — Game Design Document

## Genre

The game joins two genres: traditional roguelike and deckbuilding.

### Roguelike: Berlin Interpretation

- **Permadeath.** When your character dies, it's over. Start the run again, from the beginning.
- **Procedural generation.** Maps, item placement, and enemy encounters are generated randomly on every run.
- **Turn-based.** Time advances only when you take an action.
- **Grid-based movement.** Characters move from tile to tile on a grid.
- **Non-modal.** The whole game is played with a coherent set of commands, with no separate combat screen.
- **Complexity.** The systems have depth, enabling emergent play.
- **Resource management.** You can't get everything in a single run; you must choose.
- **Hack and slash.** Combat is the main focus.
- **Exploration and discovery.** Finding new areas and items is rewarding.

### Deckbuilding

- **Cards.** Represent a character's special techniques.
- **Deck.** The full set of cards a character owns. These cards cannot be played directly. It splits into:
	- **Draw pile.** Cards drawn into the hand come from this pile.
	- **Discard pile.** Cards discarded from the hand go here. When the draw pile is empty, the discard pile is shuffled and placed as the new draw pile.
- **Hand.** The subset of cards from the deck the character can access at any given moment. Cards in the hand can be played.

## Theme

- **Mouse.** The only character controlled by the player.
- **Burrow.** The mouse community under the ground, the character's home. Every run starts here.
- **Predators.** Enemies are natural predators of mice. They are not fantasy monsters. Drawn from real zoology. Their diet must include "small mammals".
- **Wilderness.** Maps are natural, wild environments with no human influence.
- **Mystic touch.** Mystic references such as: natural essence, energy, mild magic. It slightly elevates the animals' natural capabilities.

## Game loop

1. **Run start.** The run starts in the mouse burrow.
2. **Burrow.** The player picks a mouse class from the burrow.
3. **Initial rest area.** The mouse starts at character level 1. At this point, the player can perform the same actions available in any rest area (see step 5), though in principle they will have no resources to spend. This includes choosing the level 1 reward.
4. **First biome.** A small map with few enemies.
5. **Rest area.** The player may perform one or more of the following actions. Then they advance to the next biome.
	- Recover lost health.
	- Choose this level's reward.
	- Learn new cards.
	- Add cards to the deck from the list of learned cards.
	- Remove cards from the deck and place them into the list of learned cards.
	- Bind or unbind an imbued trophy.
	- Level up.
6. **Biome.** A medium map with several enemies. It allows exploration and gathering. Traps may be present. An elite predator guards the exit. The exit leads to a rest area, which then leads to a different biome, for a total of 5 times. The rest area after the fifth biome precedes the final boss.
7. **Final boss.** After the rest area following the fifth biome, there is a small area where the run's final boss resides.
8. **Run end.** If the mouse dies in any previous step (3–7), the run ends and we return to step 1 (permadeath). If the mouse defeats the final boss, the run is successful and we return to step 1 to start a new run.

## d20 rolls

- Dice add randomness to the game. They help determine whether characters succeed at what they attempt.
- Dice available: **d4**, **d6**, **d8**, **d10**, **d12**, **d20**.
- Some effects may grant **Favored** or **Hindered** to rolls. In these cases, two dice are rolled instead of one, and the higher or lower value is used, respectively.
- **Critical and Fumble.**
	- **Critical. Rolling a 20 on the attack die** auto-hits. Damage is calculated with the **maximum** value of all damage dice (e.g. 2d8+3 → 8+8+3 = 19).
	- **Fumble. Rolling a 1 on the attack die** auto-misses, regardless of modifiers or the target's Toughness/Resistance.

## Effects

[List of effects](./effects/index.md)

- These are the capabilities of a card, a basic attack, a trap, or an environmental hazard.
- Examples: deal damage, apply a status, push, jump, among many others.
- An effect may apply a status to a character as part of its resolution.
- Effects are instantaneous: they happen and resolve in the same turn. Statuses, on the other hand, persist beyond the turn in which they are applied (see Statuses).

## Statuses

[List of statuses](./statuses/index.md)

- Applied to a character.
- Temporary. Has a defined duration.
- Each status reduces its duration by 1 at the end of the next turn of the character holding that status. This way, if it is a benefit, the character can use it during the turn they have it before it ticks down. If it is a detriment, it affects them for at least one full turn before it can expire.
- When its duration reaches 0, the status is removed from the character.
- By default, statuses do not stack. Receiving the same status again replaces the previous one, including its duration. Individual statuses may define different stacking rules in their description.

## Characters

### Families

Each character belongs to one of these animal types:

- **Birds.** Examples: owl, hawk, eagle.
- **Mammals.** Examples: fox, otter, weasel.
- **Herptiles.** Includes amphibians and reptiles. Examples: snake, toad, salamander.
- **Invertebrates.** Examples: spider, scorpion, centipede.

### Attribute

Each character has these attributes, with higher or lower values depending on their nature.

- **Strength (STR).** Physical power.
- **Dexterity (DEX).** Agility, reflexes, and balance.
- **Constitution (CON).** Health and endurance.
- **Intelligence (INT).** Reasoning and memory.
- **Wisdom (WIS).** Perception and mental fortitude.
- **Charisma (CHA).** Confidence, poise, and charm.

### Attribute checks

A character uses an attribute to try to overcome a challenge.

- **Strength.** Lift, push, pull, or break something.
- **Dexterity.** Move with agility, speed, or stealth.
- **Constitution.** Push the body beyond normal limits.
- **Intelligence.** Reason or remember.
- **Wisdom.** Observe the surroundings or the behavior of creatures.
- **Charisma.** Influence, entertain, or deceive.

### Attack

- An attack can be performed with a **Basic Attack** or by playing a **Card**.
- Attacks have a defined accuracy to hit or affect a character.
- Each attack determines which attribute it uses to calculate effectiveness.
- There are two attack types: **Physical** and **Special**

#### Physical attack

- The attacked character uses their **Toughness** to try to negate the attack.
- The attacking character uses an **Attribute** described by the attack to increase their chance of success.
- `Hits? = (d20 roll) + (modifier) >= (target's Toughness)`

#### Special attack

- The attacked character rolls their own resistance roll to try to resist the attack.
- To resist the attack, they must use the specific resistance attribute indicated by the attack (see Resistances).
- Each special attack defines its own **Resistance** value, a number the defender must beat with their roll.
- `Resists? = (d20) + (resistance attribute modifier) >= attack's Resistance`
- If they resist: damage is halved. If the attack applied a status, the status is not applied.

#### Modifier calculation

- `modifier = (attribute - 10)`. The attribute is the one specified by the attack (physical or special).
- Examples: attribute 10 → 0, attribute 14 → 4, attribute 20 → 10.

### Basic attack

- Inherent to a character; represents their common attack technique.
- Costs no resources and is always available.
- Has a weaker effect than a card.
- The attack type is always **Physical**.
- It has these attributes:
	- **Range.** Determines the distance at which it can attack.
	- **Area of effect.** Determines which tiles it affects, and how many.
	- **Effects.** Determines what the attack does. It can perform one or more effects.
	- **Scaling.** Can scale with one or more of the character's attributes, modifying both the d20 hit roll and the subsequent damage.

### Card

[List of cards](./cards/index.md)

- Inherent to a character; represents their unique techniques.
- It has these attributes:
	- **Energy cost.** Must be paid to be played.
	- **Range.** Determines the distance at which it can be played.
	- **Area of effect.** Determines which tiles it affects, and how many.
	- **Effects.** Determines what the card does. It can perform one or more effects.
	- **Scaling.** Can scale with one or more of the playing character's attributes, depending on the card.
	- **Family.** Indicates which animal family it belongs to. Some features and trophies can affect cards of a specific family; the specific effect is defined in each trophy or feature.
	- **Type.**
		- **Attack.** Can be **Physical** or **Special**. If Special, it must indicate the resistance required by the attacked character.
		- **Defense.** Can heal, grant temporary HP, and so on.
		- **Special.** Can grant various benefits, summon creatures, and so on.

### Toughness

- Affects the probability of dodging or negating an attack from another character or trap.
- The normal value is 10, though it may range from 0 to 30.
- The higher it is, the higher the chance of resisting the attack.

### Resistances

Effects caused by cards or the environment can be resisted by some character attribute:

- **Strength.** Physically resist direct force.
- **Dexterity.** Dodge the danger.
- **Constitution.** Endure a toxic hazard.
- **Intelligence.** Recognize an illusion as false.
- **Wisdom.** Resist a mental attack.
- **Charisma.** Assert one's own identity.

### Damage

- Dice are used to calculate the damage dealt by an attack.
- The value is described in each attack.
- A flat number can be added to or subtracted from the dice. For example: 3d8 + 5
- Range notation (configurable from the menu): instead of 1d6 + 4, it can be expressed as [5 ~ 10]

### Hit Points

- Represent endurance and will to live. If they reach 0, the character **dies**.
- The value cannot be negative.
- Scales with **Constitution**.
- When a character has half or fewer of their Hit Points, they are **Wounded**. By itself it does nothing, but it may influence other effects that mention it.
- **TBD.** The concrete Hit Point value of the mouse and of the predators is still to be determined. It will be balanced against the maximum possible damage of basic attacks and cards, not the other way around.

### Temporary Hit Points

- They are additional to the character's Hit Points.
- Nothing happens if they run out.
- By default, the value is 0.
- The value cannot be negative.
- They can be granted by certain cards or other effects.
- They serve as protection against the loss of real Hit Points. When taking damage, these points are lost first.
- They are lost upon reaching a rest area.
- They do not stack. Whenever Temporary Hit Points are gained, they overwrite the ones already held, if the number is greater.

### Energy

- Resource that pushes the character beyond their limits. Consumed to play cards.
- Recovers 1 energy per turn.
- Maximum formula: `class_base + floor((INT - 10) / 2)`. The `class_base` is defined per class, in `mice/index.md`.

### Initiative

- Determines turn order for every non-player character.
- In any case, the player always goes first, and then the rest of the characters, ordered by their initiative.
- Determined by **Dexterity** when the biome is instantiated.
- This value will not be visible to the player; it is an internal value used to order non-playable characters.

### Actions per Turn

Each **action** is equivalent to one **turn**. When the player takes an action, the rest of the game elements take their own turn. Then it is the player's turn again, and so on. The actions available to any character are:
- **Move.** 1 tile, orthogonally, not diagonally.
- **Basic attack.** Not a card. Always available. Inherent to the character.
- **Play a card.** Consumes energy, depending on the card.
- **Draw cards.** All cards in the hand (including Environmental Cards) are discarded, then cards are drawn until the hand is full. Consumes 1 reload charge. Each character starts the biome with 3 charges, and recovers one charge every 5 turns. Up to a maximum of 3 charges can be accumulated.
- **Gather.** Pick something up from the ground (seed, environmental card, etc.). Available only to the player.
- **Loot.** Pick up essence and materials from a predator's corpse. Only available if the mouse is on a corpse.
- **Wait.** Consumes the turn.


## Predator

[List of predators](./predators/index.md)

Inhabit one or more biomes, depending on their nature.

### Threat level

- Each predator has a threat level, determined by its effectiveness at hunting mice, and the probability of a mouse surviving it.
- This level is immutable and inherent to the predator.
- The threat levels are:
	- **High.** For example: Redhead Centipede, Giant Bullfrog.
	- **Very High.** For example: Green Horn, Goliath Frog.
	- **Lethal.** For example: Pallas's Cat, Bald Eagle.
- Early biomes of the run contain the predators with the lowest threat level, increasing as the run advances through the following biomes.
- The predator's attributes scale according to its threat level.

### Predator intent

- All predators, at the end of their turn, reveal their next action (intent), if it is a **basic attack** or **play a card**. They also reveal their movement intent if the attack involves displacement (charge, lunge). In these cases, they cannot change action or target; they will attack, play the card, or move to where they have announced.
- The intent is revealed to the player by showing the tiles that will be affected by the predator's action.
- A special animation will show that the predator is ready to launch an attack or a card.
- The player can select the predator to see the detail of which attack or card it has prepared.

### Predator deck

- Contains 3 unique cards.
- Each card represents the predator's capabilities.

### Predator hand

- Fixed size of 3 cards.
- Starts the encounter with 3 cards in hand.

### Predator feature

- Each predator has a single feature.
- A feature may have various effects, both passive and reactive. It may alter or amplify the effects of cards or basic attacks, among other things.
- It is innate, fixed for the species. The mouse can only access it by binding a trophy crafted with materials from that predator.

### Predator corpse

- When a predator dies, it becomes a corpse.
- A corpse occupies a tile, just like a living character.
- It has a finite amount of Hit Points.
- If the corpse's Hit Points reach 0, it is destroyed and disappears.

## Mouse

### Mouse classes

[List of mouse classes](./mice/index.md)

Each mouse class determines different characteristics:
- Starting cards
- Attributes
- Basic attack
- Unique mechanic
- Level-up rewards.

### Mouse deck

- Starts the run with 12 cards (the class's starting cards).
- Can reach a maximum of 16 cards by adding cards learned during the run.

### Mouse hand

- Formula: `4 + floor((INT - 10) / 4)`.
- Examples: INT 10 → 4, INT 14 → 5, INT 18 → 6, INT 20 → 6.

### Mouse memorized cards

- During a biome's exploration, the mouse **memorizes** the cards used by predators.
- These cards are added to a list of **memorized cards** that is available at the rest area.
- Memorized cards are **forgotten** when entering a new biome, after the rest area.

### Mouse learned cards

- At a rest area, the mouse can spend **essence** to **learn** memorized cards.
- Learned cards are added to the list of **learned cards**. The amount of essence to consume depends on each card.

### Essence gathered by the mouse

- Essence is gathered by looting a predator's corpse.
- The amount gathered depends on the defeated predator, on **Wisdom**, and on chance.

### Mouse trophies

- When looting a predator's corpse, the mouse obtains a **trophy** from the predator (fang, feather, claw, etc.). The trophy carries a remnant of the predator's essence, but it is **inert** after its death.
- At rest areas, the mouse can **imbue** the trophy with **essence** (gathered from other predators). When imbued, the trophy goes from **inert** to **imbued** and binds to a bind.
- An imbued trophy grants the mouse the predator's feature as a passive.
- Imbuing a trophy costs essence. Binding and unbinding imbued trophies between binds is free.
- Binds: 3 initial. +1 at levels 3, 5, and 7. Maximum 7 binds at level 8.
- Inert trophies and unbound trophies are kept in a stash in the burrow.

### Experience

- A mouse can earn experience:
	- By defeating a predator (does not need to loot it).
	- From events.

### Level up

- A mouse can earn experience during a biome.
- At a rest area, the mouse can level up if it has earned enough experience.
- Experience is not lost between biomes.
- Level-up rewards. The player picks 1 of the options available for their class. The eligibility matrix is defined per class, in `mice/index.md`.
	- Mouse features: may have various effects, both passive and reactive.
	- Innate Cards: unique to mice
	- Attribute points

## Biomes

### Types

- **Swamp.**
- **Tundra.**
- **Wasteland.**
- **Forest.**
- **Canyon.**

### Environmental Cards

- **Single-use** cards that only work within the current biome.
- Usable only by the mouse.
- Gathered during the biome's exploration.
- When gathered, they are added to the hand.
- They do not count toward the hand limit.
- They disappear when discarded, or when changing biome.
- Examples:
	- Throw Stone
	- Throw Mud
	- Consume Plant

### Traps

[List of traps](./traps/index.md)

- Traps are static or mobile elements scattered across the biome that pose an obstacle or a danger to the mouse.
- Contact with a trap triggers it, dealing damage to the mouse and/or applying a negative status.
- A trap that has triggered is deactivated and does not reactivate.

### Environmental Hazards

[List of environmental hazards](./hazards/index.md)

- An environmental hazard is an area covering a small zone of the map and imposing a negative effect while standing in that zone.
- These areas may move slowly.
- They affect all characters in the area.
- They may impose effects such as: reduced visibility, reduced attribute (strength, dexterity, etc.), and so on.
- They do not deal damage.

### Gathering

- Consumable collectables scattered across the biome (e.g. berries on a bush, small insects, nests with material, empty shells).
- Minor effects: a berry heals 1-2 HP. They are not currency; ignoring them does not break the run.

### Events

[List of events](./events/index.md)

- An event is a non-hostile situation.
- Events are scattered across the biome.
- The mouse may interact with these events to try to obtain some kind of reward.
- The event may offer one or several attribute checks to pass.
- Interacting with the event is optional.
