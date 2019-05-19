---
layout: post
title:  "Generating Worlds with Rule-Based Procedural Generation"
date:   2019-05-17
categories: procedural_generation
---

In this post, I’ll briefly argue that a rule-based approach is an effective way to quickly iterate on procedurally generated content without getting bogged down in implementation details.  I’ll give a few examples of worlds I’ve created using this technique. 

I’ve built a few tools that let users apply these ideas themselves.  I’m finally happy enough with one, which I’m calling Generate Worlds, to release it.  If you’re interested in creating your own infinite worlds, head to the page on itch.io , where Generate Worlds is for sale.

When procedurally generating environments and objects, you often want those objects to have certain global properties, “a dungeon’s hallways should not have dead-ends” or “the city walls should enclose all the city’s buildings.”  One way to make this happen is to invent an algorithm for placing city walls and buildings that guarantees that buildings are within the walls, and a separate algorithm that generates dungeons with no dead-ends.  However, it would be easier to have a system that can simply take in a set of rules and produce environments that conform to those rules.  

A casual, visual introduction to rule-based world generation

Imagine we want to create a procedurally generate a simple dungeon world containing hallways and rectangular rooms.  We will make the world by putting together little square sections containing room and hall pieces.  Here are the six pieces we’ll use:

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_parts.svg)

 Here is a world made of those hallway and room pieces:

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/disorganized_dungeon.svg)

Clearly, we need to impose some structure.  Let’s add a constraint:

*Passageways can connect to other passageways.*

Given this constraint, the world now looks like this:

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_w_coherent_halls.svg)

We see coherent now see coherent passageways, but no structure on the rooms.  Let’s add another constraint:

*All floor space must be enclosed by walls.*

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_w_coherent_halls_and_rooms.svg)

Finally we need to specify that passageways should connect to rooms, so we add the constraint

*Passageways can connect to doors.*

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/coherent_dungeon.svg)


We now have a reasonable looking, simple dungeon layout.  To recap, the constraints are simply

1. Passageways can connect to other passageways.
2. All floor space must be enclosed by walls.
3. Passageways can connect to doors.

Creating these rules is easy compared to writing a dungeon generation algorithm, but it’s hard to convert an english statement like “Passageways can connect to other passageways.” to a set of unambiguous rules, so I’ll instead rely on a 3D visual language.  This language consists of voxel tiles that the user provides.  Imagine we want to create a world with walled cities and countryside.  Here’s what the tiles for that world might look like:


![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/labeled_woods_tiles.svg)


The world should have the following properties:
* Rivers have no dead ends
* Roads have no dead ends
* Roads can cross rivers over a bridge
* Roads can cross into cities through a gate
* Walls separate the outside grassy areas from town interiors
* Grassy areas can contain huts and trees

To enforce these properties, Generate Worlds simply ensures that two tiles are only placed next to each other if the cubes that touch are all the same color, as in the example below.

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/road_assembling.svg)

*We can arrange these two tiles in this way because the tiles’ colors match where they touch.*

Placing several tiles looks like this:

<div style="width:100%;height:0;padding-bottom:56%;position:relative;"><iframe src="https://giphy.com/embed/3DHNvMhDA6FEun6keU" width="100%" height="100%" style="position:absolute" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe></div>

These tiles are easy to create in a voxel editor like MagikaVoxel.  The tile set above is simply a directory of .vox files that Generate Worlds takes as input.

## A more complex world

Let’s say we want to generate a 3D dungeon that extends endlessly in all directions.  We can simply provide Generate Worlds with a new tile set of dungeon parts.  Nine of those tiles are shown below.  They contain pieces of passageways, rooms, and stairs.

![depth from motion graph]({{ site.url }}/assets/rule_based_procedural_generation/dungeon_tiles.png)


Putting them together in 3D looks like this:

<iframe src="https://giphy.com/embed/2kPO91XMLHeC1JCo4w" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe><p><a href="https://giphy.com/gifs/2kPO91XMLHeC1JCo4w"></a></p>

Loading these .vox files into Generate Worlds, I can explore this dungeon world in first-person.  Generate Worlds lets you set lighting conditions, and place lights.

<iframe src="https://giphy.com/embed/L0lYvytfI6j7gS47hC" frameborder="0" class="giphy-embed" allowfullscreen=""></iframe><p><a href="https://giphy.com/gifs/2kPO91XMLHeC1JCo4w"></a></p>










