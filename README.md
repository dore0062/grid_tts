# grid_tts
TTS grid is used to make simple scripting zone grids for tabletop simulator, so you can more easily create advanced games that use grids.

- [grid_tts](#grid-tts)
  * [Usage:](#usage-)
    + [Atom:](#atom-)
    + [Creating a new grid:](#creating-a-new-grid-)
  * [Commands](#commands)
    + [Grid:circle(mode, x0, y0, radius)](#grid-circle-mode--x0--y0--radius-)
    + [Grid:rectangle(mode, startX, startY, width, height)](#grid-rectangle-mode--startx--starty--width--height-)
    + [function Grid:line(mode, startX, startY, endX, endY)](#function-grid-line-mode--startx--starty--endx--endy-)
    + [Other commands:](#other-commands-)
  * [Example usage:](#example-usage-)
  
## Usage:

### Atom:
First save to your atom's code folder as <code>grid_tts.ttslua</code> (*NOT* .lua)
#include grid_tts

### Creating a new grid:
First initialize your grid with
<code>Myvalue = Grid:new()</code>
  
You can now use Myvalue to preform grid functionality. The first command you should preform is

<code>Myvalue:spawn(grid_width, grid_height, y_offset, x_offset, z_offset, cell_width, cell_height, cell_padding, spawn_location)</code>

This will spawn scripting zones and place the scripting zone objects into the table. Your grid is now ready for use! To save the grid, just save the variable like you normally would in TTS.

## Commands

### Grid:circle(mode, x0, y0, radius)
Iterates through a circular area

| Variable | Usage            | Type   |
|----------|------------------|--------|
| mode     | fill or line     | string |
| x0       | Center x value   | number |
| y0       | Center y value   | number |
| radius   | Radius of circle | number |

### Grid:rectangle(mode, startX, startY, width, height)
-- Iterates through a rectangular area

| Variable | Usage               | Type   |
|----------|---------------------|--------|
| mode     | fill or line        | string |
| startX   | Lower left x value  | number |
| startY   | Lower left y value  | number |
| width    | Width of rectangle  | number |
| height   | Height of rectangle | number |

### function Grid:line(mode, startX, startY, endX, endY)
-- Iterates through a line

| Variable | Usage           | Type   |
|----------|-----------------|--------|
| mode     | rigid or smooth | string |
| startX   | Starting x      | number |
| startY   | Starting y      | number |
| endX     | Ending x        | number |
| endY     | Ending y        | number |

### Other commands:
* **Grid:iterate()** : Iterate through the entire grid.
* **Grid:clean()** : Cleans any empty rows.
* **Grid:get(x, y)** : Get the scripting zone of a cell

## Example usage:
Use interchangably with any iteration, it all works the same.
<code>for x, y, v in special_grid:circle("fill", 2, 2, 1) do print("Circle: ", x, ",", y, " ", v) end</code>

## Custom grids:
If you want to have custom scripting zones sizes, then you can include set them into the grid (the grid is initialized as a table)
