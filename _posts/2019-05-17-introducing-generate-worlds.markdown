---
layout: post
title:  "Introducing Generate Worlds for Procedural Generation without Code"
date:   2019-05-17
categories: procedural_generation
published: true
---


I want to give everyone the ability to create and explore infinite, procedurally generated worlds without writing a single line of code.  

The infinite procedurally generated worlds of games like Minecraft and Dwarf Fortress create a sense of exploration and variety that entirely hand-built game worlds cannot compete with.  However, designing and coding the algorithms to actually perform this generation is a specialized technical skill few possess.  At the same time, numerous online communities exist around mapping, painting, and otherwise imagining fantasy environments, and some great products exist to help them do it, like [Wonderdraft](https://www.wonderdraft.net/) for drawing fantasy maps.  But something is missing: I want to experience these worlds from the inside, and drawing tools don’t let me do it.

My desire to design and explore fantasy landscapes inspired me to build the procedurally generated island worlds of [Brimming Sea](http://www.brimmingsea.com/) in 2014.  It was a difficult technical task, but imagining and then walking around these islands was magical.  Since then, I’ve created several tools to help me design infinite procedural worlds *without writing any code*, and I’m finally happy enough with one of those tools to release it.  I’m calling it Generate Worlds, and it’s available on the itch.io store.

<iframe frameborder="0" src="https://itch.io/embed/406212?linkback=true&amp;border_width=2&amp;bg_color=353535&amp;fg_color=ffffff&amp;link_color=fa5c5c&amp;border_color=333333" width="100%" height="169"></iframe>


This video briefly describes Generate Worlds.  Read on for the details.


<iframe width="100%" height="370" src="https://www.youtube.com/embed/DrAtX-EsQM0?autoplay=0&amp;showinfo=0" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen=""></iframe>




## Generate Worlds with Rules instead of Code

The key idea behind Generate Worlds is that instead of writing code that describes how to build the world, you simply create a set of rules about how you want the world to work and Generate Worlds puts it together for you.  Let’s start with a simple example.

Imagine we want to create a simple dungeon world containing hallways and rectangular rooms.  We will make the world by assembling these six passageway and room pieces:

![dungeon parts]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_parts.svg)


I'll now add a series of rules to put these pieces together into a coherent dungeon, starting with an unstrucutred world made of those pieces but without any rules about how to put them together:

![dungeon construction]({{ site.url }}/assets/rule_based_procedural_generation/full_dungeon_sequence.svg)


We now have a reasonable looking, simple dungeon layout.  To recap, the rules are simply

1. Passageways can connect to other passageways.
2. All floor space must be enclosed by walls.
3. Passageways can connect to doors.

## 3D Tiles Instead of Engish Rules

Creating these rules is easy compared to writing a dungeon generation algorithm, but it’s hard to convert an english statement like “Passageways can connect to other passageways” to a world, so I’ll instead rely on a 3D visual language.  This language consists of voxel *tiles* that the user provides.  These tiles are simple .vox files that a user creates in some voxel editing software and loads into Generate Worlds.  Imagine we want to create a world with walled cities and countryside.  Here’s what the tiles for that world might look like:


![town and country tiles]({{ site.url }}/assets/rule_based_procedural_generation/labeled_woods_tiles.svg)


The world should have the following properties:
* Rivers and roads have no dead ends
* Roads can cross rivers over a bridge
* Roads can cross into cities through a gate
* Walls separate the outside grassy countryside from town interiors
* Grassy areas can contain huts and trees

To enforce these all these rules, Generate Worlds does only one simple thing:  it ensures that two tiles are only placed next to each other in the world if the tiles are the same color in all the places where they touch, as in the example below.

![two road tiles assembling]({{ site.url }}/assets/rule_based_procedural_generation/road_assembling.svg)

*In the figure above, we can arrange these two tiles in this way because the tiles’ colors match where they touch.*

Placing several tiles looks like this:

<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/3DHNvMhDA6FEun6keU" width="100%" height="100%" style="position:absolute" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe></div>

These tiles are easy to create in a voxel editor like MagikaVoxel.  The tile set above is simply a directory of .vox files that Generate Worlds takes as input.

## Generating a Dungeon

Let's try a more sophisticated world: a 3D dungeon that extends endlessly in all directions.  We can simply provide Generate Worlds with a new tile set of dungeon parts.  Nine of those tiles are shown below.  They contain pieces of passageways, rooms, stairs, columns, arcades, and doorways.

![dungeon tiles]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_tiles.svg)


Putting them together in 3D looks like this:


<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/2kPO91XMLHeC1JCo4w" width="100%" height="100%" style="position:absolute" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe></div>


Loading these .vox files into Generate Worlds, I can explore this dungeon world in first-person.  Generate Worlds lets you set lighting conditions, and place lights.


<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/L0lYvytfI6j7gS47hC" width="100%" height="100%" style="position:absolute" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe></div>


## Conclusion

My goal is to build a creative tool that isn't quite like anything already in existence.  Minecraft lets you modify worlds block by block and explore them, but it doesn't let you redefine how the world is created in the first place, limitting the scope of what you can build.  Mapping and drawing tools help you imagine and design worlds, but don't let you explore them.  Finally, coding your own algorithms gives you huge flexibility, but at the cost of muhch higher difficulty.  And for what it's worth, the worlds I've made in Generate Worlds are more varied and compelling than what I've been able to create by hand-building procedural generation algorithms in the past.

If you want to explore this creative avenue, consider supporting this effort by purchasing Generate Worlds.  A [tutorial](http://generateworlds.com/tutorial.html) is available to get you started.  If you have any issues using it, you can contact me at ijdykeman@gmail.com .  
