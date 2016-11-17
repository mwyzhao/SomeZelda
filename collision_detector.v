/*** contains memory for a level graph of map
	 also does computation for character collision ***/

/* x,y coordinates of all characters are wired into this
 * module where it is then used to calculate if collision will occur
 * active when c_collision bit from control module is high */

/* whoever will be writing this in the future feel free to do whatever
   you want with this section as long as it works */

/* tentative module declaration */

/* 

module collision_detector(
	input clock,
	input reset,

	//enable signal from control
	input c_c_enable,

	//position for player character
	input		x_char,
	input		y_char,

	//position for enemies
	input		x_enemy1,
	input		y_enemy1,

	input 		x_enemy2,
	input		y_enemy2,

	/* output signals indicating if any collisions have occurred
	 * set to 1 if true, 0 if false */
	/* these signals are sent to the character and enemy logic modules
	 * which will adjust the path necessarily */
	/* c = player character, e1 = enemy1, e2 = enemy2 */
	output reg	c_map_collision,
	output reg	e1_map_collision,
	output reg	e2_map_collision,
	output reg	c_e1_collision,
	output reg	c_e2_collision,
	output reg	e1_e2_collision,
	output reg 	c_attack_e1,
	output reg	c_attack_e2
	);

	map_level_mem mm(...);

	collision calculations
	mostly checking if the areas of the sprites overlap
	and sending the correct signals

endmodule

*/