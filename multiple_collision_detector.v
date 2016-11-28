module multiple_collision_detector(
	input clock,
	input reset,
	input init,

	//enable signal from control
	input collision_enable,

	//position for player character
	input		[8:0] char_x,
	input		[7:0] char_y,
	input 		[2:0] direction_char,
	input 		[2:0] facing_char,
	input 		attack,
	//position for enemies
	input		[8:0] enemy1_x,
	input		[7:0] enemy1_y,
	input 		[2:0] direction_enemy1,
	input 		[2:0] facing_enemy1,

	input		[8:0] enemy2_x,
	input		[7:0] enemy2_y,
	input 		[2:0] direction_enemy2,
	input 		[2:0] facing_enemy2,

	input		[8:0] enemy3_x,
	input		[7:0] enemy3_y,
	input 		[2:0] direction_enemy3,
	input 		[2:0] facing_enemy3,

	/* output signals indicating if any collisions have occurred
	 * set to 1 if true, 0 if false */
	/* these signals are sent to the character and enemy logic modules
	 * which will adjust the path necessarily */
	/* c = player character, e = enemy1, e2 = enemy2 */
	output	c_map_collision,

	output	e1_map_collision,
	output	c_e1_collision,
	output  e1_hit,

	output	e2_map_collision,
	output	c_e2_collision,
	output  e2_hit,

	output	e3_map_collision,
	output	c_e3_collision,
	output  e3_hit,
	
	output	done,
	);

	assign done = done1&done2&done3;

	collision_detector c1(.clock(clock),
						  .reset(reset),
						  .init(init),
						  .collision_enable(collision_enable),
						  .char_x(char_x),
						  .char_y(char_y),
						  .direction_char(direction_char),
						  .facing_char(facing_char),
						  .attack(attack),
						  .enemy_x(enemy1_x),
						  .enemy_y(enemy1_y),
						  .direction_enemy(direction_enemy1),
						  .facing_enemy(facing_enemy1),
						  .c_map_collision(c_map_collision),
						  .e_map_collision(e1_map_collision),
						  .c_e_collision(c_e1_collision),
						  .e_hit(e1_hit),
						  .done(done1)
						  );
	collision_detector c2(.clock(clock),
						  .reset(reset),
						  .init(init),
						  .collision_enable(collision_enable),
						  .char_x(char_x),
						  .char_y(char_y),
						  .direction_char(direction_char),
						  .facing_char(facing_char),
						  .attack(attack),
						  .enemy_x(enemy2_x),
						  .enemy_y(enemy2_y),
						  .direction_enemy(direction_enemy2),
						  .facing_enemy(facing_enemy2),
						  //.c_map_collision(c_map_collision),
						  .e_map_collision(e2_map_collision),
						  .c_e_collision(c_e2_collision),
						  .e_hit(e2_hit),
						  .done(done2)
						  );
	collision_detector c3(.clock(clock),
						  .reset(reset),
						  .init(init),
						  .collision_enable(collision_enable),
						  .char_x(char_x),
						  .char_y(char_y),
						  .direction_char(direction_char),
						  .facing_char(facing_char),
						  .attack(attack),
						  .enemy_x(enemy3_x),
						  .enemy_y(enemy3_y),
						  .direction_enemy(direction_enemy3),
						  .facing_enemy(facing_enemy3),
						  //.c_map_collision(c_map_collision),
						  .e_map_collision(e3_map_collision),
						  .c_e_collision(c_e3_collision),
						  .e_hit(e3_hit),
						  .done(done3)
						  );

endmodule