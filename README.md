<h1 align="center">Boppie Evolution</h1>

---

# Try it [online](https://boppie-evolution.brutenis.net)! 

## A Simulation of Natural Selection based on Owl-like Creatures with Neural Networks

![](./Media/Simulation1.gif)


![](./Media/Simulation2.gif)

## Explanation

There are two types of boppies: owlies and kloppies. The owlies eat the red dots (apples), and the kloppies eat the owlies. 

![](./Media/FoodChain.png)

Each creature has a small neural network which tells it what to do. The neural network has two outputs, go forward/backwards and turn left/right. Notice in the gif below the two output nodes.
Currently each creature has 5 inputs (+1 bias/threshold), each input shows the distance (0 = no food, 0.5 = very far, 1.0 = very close) to the next food. As in, the neuron fires when it sees
food there.

![](./Media/Simulation3.gif)

## Observations

Based on this basic neural network and evolution some interesting behaviour emerges. For example, the
[prey-predator](https://en.wikipedia.org/wiki/Lotka%E2%80%93Volterra_equations) cycle appears after some time, just as it does in nature:

![](./Media/PreyPredatorCycle.png)

## Running it

You can play with it [online](https://boppie-evolution.brutenis.net) with a web browser.
For better performance you can download the binaries [here](https://github.com/LiquidFun/BoppieEvolution/releases/latest) (Linux, Windows and Mac are all provided, the latter two have not been tested though).

## Hotkeys

Quickstart: after starting a simulation: press `9` to simulate quickly. After a couple minutes you can press `1` to go to normal speed and inspect what the creatures are now capable of!

* `H` - See help page for up-to-date hotkey list (or click on the question mark in the bottom right corner)
* `W`/`A`/`S`/`D` - move camera around (hold **shift** to move 10x as fast)
* `Mouse click and drag` - move camera around
* `Mouse click` on boppie - follow it until it dies
* `Mouse wheel` - zoom in/out
* `Escape` - stop following boppie
* `O`/`K` - follow fittest **o**wlie/**k**loppie until it dies
* `P` - turn performance mode on/off (off by default). This improves FPS by a lot by turning off all particles and unnecessary visual effects. This is done automatically when changing to a time factor above 32x.
* `F` - **f**ollow new fittest boppie even after death
* `C` - toggle **c**ontrol of boppie if already following it (i.e. clicked on it before) (use `W`/`A`/`S`/`D` to move with it)
* `E` - add 5 **e**nergy to currently following boppie (press multiple times, then the boppie will grow and have children)
* `-`/`+` - decrease/increase time factor by 2x (min: 0.5x, max: 256x)
* Numbers `1` through `9` - set time factor to 2^(number - 1)  (e.g.: pressing 9 sets time factor to 256x)
* `Space` - pause/unpause
* `R` - show vision **r**ays for all boppies
* `T` - show vision rays for curren**t** boppie

## If you want to tinker yourself

* Download the free and open source game-engine: [Godot](https://godotengine.org/)
* Clone this repository: `git clone https://github.com/LiquidFun/BoppieEvolution` (or download via github)
* Open Godot and import the `project.godot` file
* Now press on the play button to run it 

## Ideas for future features

### Simulation

* Add obstacles
* Add more senses for the boppies, such as:
    * Instead of rays try neural network inputs with information for angle+distance
    * Cone for detection of food
    * Your own kin (so that ant-like behaviour could emerge)
    * Timer
    * History neuron both input/output, but cap with sigmoid as it easily escalates
* Add sexual reproduction, as in the real world merging DNA from two individuals has greatly benefited survival of the fittest
* Add loading/saving of simulations
* Add areas of high ground productivity (where more food spawns)
* Add (for example), a river in the middle of the map, which separates the species on the left/right of it. 
* Encode how many creatures are reproduced in the DNA of the creature
* Make boppies leave flesh after death
* Change meat-eating from boolean to a float, where it essentially becomes meat-tolerance or meat effectiveness (a factor of how much energy can be gained from meat). However high meat-tolerance means low 
* Extend boppie color as part of DNA 
    * Ideas: 
        * HSL (where H is part of DNA, S shows energy, L = .5 or meat-tolerance )
        * RGB (where R, G is part of DNA, B shows meat-tolerance)
* Add reinforcement learning
    * Save which neurons most contributed to a reward in the last seconds (eating)/penalty (taking damage), increase the weights of those connections
* Different parallel simulations where the best are merged into one

### UI/UX
* Add menu so that simulation could be configured
* Show genetic tree for entire simulation
* Add more graphs 
    * Fittest creature each second
    * Species stacked bar-plot
* Select different profiles for displaying neural network (weights or activations)
* Full screen on neural network, which shows actual weights
* Improve display of recurrent connections
* Check DNA importing, such that no object references are mentioned in the DNA
* Use textures on the ground (fertile vs infertile land)
* Show version/commit id in application
* Make the fittest tab somehow always selectable
* Add world configuration tab with seed and other such stuff

### Experiments

* Can the boppies learn recurrent connections if their inputs are delayed


## Changelog

### v0.3.0 (not yet released)

* UI/UX Improvements
    * Show additional danger-sense near boppie
    * Disabled spike rotation and blood in performance mode
    * Improved graphs by drawing lines instead of pixels in texture, graphs can be hidden

### [v0.2.0](https://github.com/LiquidFun/BoppieEvolution/releases/tag/0.2.0) (2022-02-17)

* UI/UX Improvements
    * Random seed is shown 
    * Can now drag boppies from fittest list into world
    * Camera can now be moved by dragging the mouse
    * DNA/Neural network as tabs, as they did not fit in a single column
    * Neural networks now show what each input/output neuron means
* Neural networks can have any structure (not necessarily fully connected)
* Added rotating traps with spikes and blood marks after death
* Added these senses for boppies:
    * Danger sense (for detecting traps and kloppies)
* Added boppie color as part of DNA 
* Implemented NEAT (Neuroevolution of Augmenting Topologies), such that the neural networks of the boppies change with each generation
    * Added an innovation number for each connection in the neural network, as described in NEAT
    * Crossover of creature DNA and neural networks


### [v0.1.0](https://github.com/LiquidFun/BoppieEvolution/releases/tag/0.1.0) (2021-10-19)

* Two types of creatures (Owlies and Kloppies)
* A basic neural network for each creature
* Creatures have DNA which they pass on to children
* Vision based on 5 rays extending from each boppie

## Inspired by

### Videos

* [Evolution simulator](https://www.youtube.com/watch?v=GOFws_hhZs8) by [carykh](https://www.youtube.com/channel/UC9z7EZAbkphEMg0SP7rw44A)
* [Evolv.io](https://www.youtube.com/watch?v=C9tWr1WUTuI) by [carykh](https://www.youtube.com/channel/UC9z7EZAbkphEMg0SP7rw44A)
* [MarI/O](https://www.youtube.com/watch?v=qv6UVOQ0F44) by [SethBling](https://www.youtube.com/channel/UC8aG3LDTDwNR1UQhSn9uVrw)
* [Simulating Natural Selection](https://www.youtube.com/watch?v=0ZGbIKd0XrM) by [Primer](https://www.youtube.com/channel/UCKzJFdi57J53Vr_BkTfN3uQ)
* [I programmed some creatures. They Evolved.](https://www.youtube.com/watch?v=N3tRFayqVtk) by [David Randall Miller](https://www.youtube.com/user/davidrandallmiller)
* [The Evolution of Predation in a Simulated Ecosystem](https://www.youtube.com/watch?v=rPkMoFJNcLA) by [The Bibites: Digital Life](https://www.youtube.com/c/TheBibitesDigitalLife)

### Papers

* [Neuroevolution of Augmenting Topologies](http://nn.cs.utexas.edu/downloads/papers/stanley.ec02.pdf) by K. Stanley and R. Miikkulainen, 2002
