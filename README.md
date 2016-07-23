Civplicity
==========

*A simpler Civ game.*

#### Tests

`ruby civ.rb`

###### Changes

Long story short. It's Civ, simplified.

The game rules have been simplified to make play mechanics less of a black box while still supporting 5 different victory modes.

Build cities on tiles, research techs, develop militaries, conquer other civs.

There is no farming, no trade, no buildings, no spying, and no unhappiness.

A city can be built on any land tile. There are no borders.

Each land tile has two scores: nutrients and minerals. A high nutrient score increases civilians, and a high mineral score increases your production rate.

Building a unit costs one civilian. You cannot create more units than your population.

If you have more civilians than units stationed in a city, your city's culture grows by year according to the extra number of civilians.

This means you have to leave a city more or less undefended for it to gain culture.

If your culture reaches 20,000, your city becomes Legendary. If three of your cities go legendary, you win the game, even if they are conquered later.

Your civ's research points increase according to the highest population of any one city within your control, even if you conquered it.

Combat has three outcomes: win, lose, or draw. Which outcome you get is entirely random with 4 exceptions.

Those 4 exceptions are that the following challengers cannot lose: a player challenging another player under a treaty, a tank challenging a city, a veteran challenging a non-veteran, a conscripted unit challenging a non-conscripted unit.

Diplomacy is also made simpler: either propose peace or declare war. War is the default.

Government: Either choose anarchy or monarchy. Anarchy is the default.

If your capital city is conquered, your civ reverts to Anarchy until you get your capital city back. You cannot change capitals.

You must be a Monarchy to participate in the UN. You must have Conscription to establish the UN. You get an extra vote if you establish it.

If a civ declares war on any UN civ, it automatically gets removed from the UN until peace is restored.

Combat is not an automatic declaration of war. Sieging a city is.

The UN is dissolved if the world population within the UN falls below 50%.

The UN cannot be reconvened until 25 years passes after it dissolves. Like other civ games, each successive turn lasts a shorter number of years.

There is only one possible UN vote: whether or not to end the game.

###### How to achieve victory (strategy):

1) Conquest

Simply put, get nukes before anyone else and nuke your enemies into oblivion.

You: +2 points, everyone else: 0 points

2) Space Race

Always make sure you hold the city with the highest population worldwide. Get the Spaceship tech.

You: +2 points, everyone else: 0 points

3) Domination

Produce lots of cities and units. Conquer a capital, propose peace with the civ. Rinse, repeat.

You: +2 points, everyone else alive: 1 point.

4) Culture

Stay at peace with neighbors at all costs. Seek out peninsulas and islands for culture centers and maintain naval dominance.

You: +2 points, everyone else alive: 1 points.

5) Diplomacy

Ally with peaceful players, establish the UN, and perform peacekeeping missions (meaning roam the world and fight treaty-breakers).

You: +2 points, everyone else in the UN: 1 point.

###### Tech tree

Table:

```
Tech            Bonus                   Required for                    
Money                                   Monarchy                       
Wheel                                   Combustion                    
Farming         +200% Nutrients         Medicine                       
Ironworking                             Steel                        
Chemistry       +25% Nutrients          Medicine, Combustion           
Astronomy       +Can build Boat         Calculus                        
Monarchy        +Can be Monarchy        Conscription                    
Combustion                              Spaceship, Atomic Theory        
Steel                                   Spaceship, Atomic Theory
Medicine        +40 max population      Spaceship
Calculus        +50% research           Spaceship, Atomic Theory
Conscription    +Can estabish UN        Spaceship, Atomic Theory
Spaceship       +You win                
Atomic Theory
```

Flowchart:

```

 Ironworking--->Steel----------------------x         
                                            \        
 Money--------->Monarchy---->Conscription----x----x--->Atomic Theory
                                            /      \ 
 Wheel-------x->Combustion-----------------x        \
            /                             /          \
 Chemistry-/                             /            \
                                        /              \
 Astronomy----->Calculus---------------x                \
                                                         \
 Farming------->Medicine----------------------------------x->Spaceship
```

###### Units

Unit selection is smaller:

```
Unit                    Techs required
Archer                  (None)
Chariot                 Farming, Wheel
Swordsman               Ironworking
Boat                    Astronomy
Infantry                Conscription
Cavalry                 Conscription, Farming, Wheel
Tank                    Conscription, Steel, Combustion
Gunship                 Conscription, Steel, Astronomy
Nuke                    Atomic Theory
```

###### AI

Stage 1: Conquerors, Space Racers, Diplomats, and Culturers are expanding and defending. Dominators are getting ready for war.

Stage 2: UN is established, probably by a Diplomat. Culturers are eager to get on board. Legendary cities start appearing, and Conquerors and Space Racers fight over for them. Dominators and Culturers fight for the seas.

Stage 3: Someone, probably a Conqueror, Diplomat, or Culturer, has nukes. Conquerors go after the weak first, and Culturers go after the strong first. Diplomats are faithful to UN members who vote for them. Dominators are opportunists and often break treaties. Space Racers don't have nukes, so they stay out of it and defend their cities. Diplomats try and ally with Dominators, Space Racers and weak civs to rush a UN vote.

