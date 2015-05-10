##########################################################################################################################################################################################################################################################################################################################################################################
# 
# This is a component based 2D Shooter game, part of the "Let's Make a Game..." Series Tutorials by: Tom Morley URL:
# 
# *** Special thanks to Kyle Luce for code help and bug smashing on this game. ***
# 
# Graphics used in this game were provided by:
#	Ship - http://millionthvector.blogspot.com/p/free-sprites.html		CC 4.0
#   Laser - http://opengameart.org/content/space-shooter-redux		CC0 1.0 Universal
# 	Rocks - http://forum.thegamecreators.com/?m=forum_view&t=209786&b=41		Used with permission from Phaelax
# 	Background - Image credit: ESA/PACS & SPIRE consortia, A. Rivera-Ingraham & P.G. Martin, Univ. Toronto, HOBYS Key Programme (F. Motte)
#                http://www.jpl.nasa.gov/spaceimages/details.php?id=PIA16883                                                                                                                                                                                                                                                                                    #
#                                                                                                                                                                                                                                                                                                                                                                        #
##########################################################################################################################################################################################################################################################################################################################################################################

extends Node

var game_running = false

#Preload the gui sceene and set vars.
var gui = preload("res://gui/gui.scn")
var score = 0
var high_score = 0


#Preload the laser sceene and set laser vars.
var laser = preload("res://laser/laser.scn")
var laser_speed = 20
var laser_count = 0
var laser_array = []
var thrust_sound_channel = 100

# preload the rock sceene and set rock vars.
var rock = preload("res://rock/large_rock.scn")
var rock_count = 0
var rock_array = []
var rock_velocity = Vector2(0,90)

# set ship vars.
export var ship_speed = 100
export var acceleration = 10
var current_speed = Vector2(0,0)


# Initalization code - set things up and turn on our fixed process:
func _ready():
	
	set_fixed_process(true)
	set_process_input(true)
	var gui_root = gui.instance()
	add_child(gui_root)
	gui_root.set_owner(self)
	
	
# The fixed process function is called once every physic frame:
func _fixed_process(delta):
	if game_running  == true:
		run_game(delta)
	elif game_running == false:
		if (Input.is_action_pressed("Enter")):
			start_game()
	
	
func run_game(delta):
	
	
	# Check for key input and move ship
	if (Input.is_action_pressed("ui_up")):
		get_node("KinematicBody2D/Sprite/thrust_up").show()
		if ! get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").is_active(): 
			thrust_sound_channel = get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").play("thrust",false)
		move(current_speed.x, -ship_speed, acceleration, delta)
		
	else:
		get_node("KinematicBody2D/Sprite/thrust_up").hide()
		
	if (Input.is_action_pressed("ui_down")):
		if ! get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").is_active(): 
			thrust_sound_channel = get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").play("thrust",false)
			
		get_node("KinematicBody2D/Sprite/thrust_down_1").show()
		get_node("KinematicBody2D/Sprite/thrust_down_2").show()
		move(current_speed.x, ship_speed, acceleration, delta)
	else:
		get_node("KinematicBody2D/Sprite/thrust_down_1").hide()
		get_node("KinematicBody2D/Sprite/thrust_down_2").hide()
		
	if (Input.is_action_pressed("ui_left")):
		get_node("KinematicBody2D/Sprite/thrust_left").show()
		move(-ship_speed, current_speed.y, acceleration, delta)
		if ! get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").is_active(): 
			thrust_sound_channel = get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").play("thrust",false)
	else:
		get_node("KinematicBody2D/Sprite/thrust_left").hide()
		
	if (Input.is_action_pressed("ui_right")):
		get_node("KinematicBody2D/Sprite/thrust_right").show()
		move(ship_speed, current_speed.y, acceleration, delta)
		if ! get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").is_active(): 
			thrust_sound_channel = get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").play("thrust",false)
	else:
		get_node("KinematicBody2D/Sprite/thrust_right").hide()
		
	if (! Input.is_action_pressed("ui_up")) and (! Input.is_action_pressed("ui_down")) \
		and (! Input.is_action_pressed("ui_left")) and (! Input.is_action_pressed("ui_right")):
		move(0, 0, acceleration, delta)
		get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").stop(thrust_sound_channel)
		
		
	# Check for ship collision and end game if colliding with a rock.
	var the_collision_node = ""
	if get_node("KinematicBody2D").is_colliding():
		the_collision_node = get_node("KinematicBody2D").get_collider().get_name()
		# first check to se if the ship is colliding with a rock and if it is delte the rock
		if (the_collision_node == "RigidBody2D"):
			get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_explosion/").play("explosion",false)
			# get the name of the rock instance that hit the ship.
			rock_array.remove(rock_array.find(get_node("KinematicBody2D").get_collider().get_parent().get_name()))
			# remove and delete the rock instance that hit the ship.
			get_node("KinematicBody2D").get_collider().get_parent().queue_free()
			# we know the ship is colliding so implement "slide motion" on the ship so it wont "stick" to the rock it collides with.
			#var n = get_node("KinematicBody2D").get_collision_normal()
			#current_speed = n.slide( current_speed )
			# get_node("KinematicBody2D").move(current_speed)
			# The ship got hit end the game!!!!!!!
			end_game()
			
		else:
			# we know the ship is colliding so implement "slide motion" on the ship.
			var n = get_node("KinematicBody2D").get_collision_normal()
			current_speed = n.slide( current_speed )
			get_node("KinematicBody2D").move(current_speed)
			
		
		
	# loop through the lasers and move them all up.
		
		 
	var laser_id = 0
	var rock_node_path = null
	var laser_node_path = null 
	for laser in laser_array : 
	
		if  get_node(laser) != null:         
			var laser_pos = get_node(laser).get_pos()
			laser_pos.y = laser_pos.y - laser_speed * delta
			#print(str(laser_pos.y) + " ----- " + str(get_node("KinematicBody2D").get_pos().y))
			get_node(laser).set_pos( laser_pos + Vector2(0,- laser_speed))
			if laser_pos.y + 100 < get_node("KinematicBody2D").get_pos().y:
				get_node(str(laser) + "/KinematicBody2D").set_layer_mask(1)
			#remove the laser_root from the array and delete the child from the main scene if off top of screen
			if laser_pos.y < -100:
				laser_array.remove(laser_array.find(laser))
				get_node(laser).queue_free()
				
				
		if get_node("/root/ship_root/" + str(laser) + "/KinematicBody2D") != null: 
			if (get_node("/root/ship_root/" + str(laser) + "/KinematicBody2D").is_colliding()):
				 
				#  remove the rock_root from the array and delete the child from the main scene
				print(laser_array ) 
				print(rock_array)
				if get_node("/root/ship_root/" + str(laser) + "/KinematicBody2D").get_collider() != null:
					var node_path = get_node("/root/ship_root/" + str(laser) + "/KinematicBody2D").get_collider().get_parent().get_path()
					print(get_node("/root/ship_root/" + str(laser) + "/KinematicBody2D").get_collider().get_parent().get_path())
					rock_array.remove(rock_array.find(get_node(node_path).get_name()))
					get_node(node_path).queue_free()
				
				#remove the laser_root from the array and delete the child from the main scene
				laser_array.remove(laser_array.find(laser))
				get_node(laser).queue_free()
				
				get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_explosion/").play("explosion",false)
			
				
				##################### SCORE!!!!!!!!!! ##############################3
				score += 10
				increase_gui_score(score)
			else:
				get_node(str(laser) + "/KinematicBody2D").move(Vector2(0,-1))
		
		
		laser_id += 1 
	
	#Check to see if rock is out of bounds and delete it if it is.
	var rock_id = 0
	for rock in rock_array:
 
		#print(get_node(rock).get_path())
		var rock_pos = get_node(str(rock)).get_node("RigidBody2D").get_pos()
		#print(rock_pos)
		#print(get_node(str(rock)).get_node("RigidBody2D").get_linear_velocity())
		if (rock_pos.y > 2600):
			rock_array.remove(rock_id)
			get_node(rock).queue_free()
			#print("Kill Rock!!!")  
			
		rock_id += 1			
	
	
# Create an input event to capture the spacebar "click"
func _input(event):
	# keyboard events will send echo
	if event.is_action("space") && event.is_pressed() && !event.is_echo() && game_running:
		fire()
		get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_laser").play("shoot_small",false)
		
		
# create a move function with acceleration/deceleration:
func move(speed_x, speed_y, acc, delta):
	current_speed.x = lerp(current_speed.x, speed_x, acc * delta)
	current_speed.y = lerp(current_speed.y, speed_y, acc * delta)
	get_node("KinematicBody2D").move(Vector2(current_speed.x, current_speed.y))
	
# create a fire laser function adding new lases to an array.
func fire():     
	laser_count += 1
	var laser_instance = laser.instance()
	laser_instance.set_name("laser"+str(laser_count))
	laser_instance.set_scale(Vector2(2,2))
	add_child(laser_instance)   
	laser_instance.set_owner(self)
	get_node("KinematicBody2D").add_collision_exception_with(laser_instance)    
	get_node("laser" + str(laser_count) + "/KinematicBody2D").add_collision_exception_with(get_node("KinematicBody2D"))
	get_node("laser" + str(laser_count) + "/KinematicBody2D").add_collision_exception_with(get_node("top_boundary"))         
	laser_instance.set_pos(get_node("KinematicBody2D").get_pos()) 
	laser_array.push_back("laser"+str(laser_count))  
	                                                                                 
	
# this function was created by linking the "Timer Node" connection to this node. It will be called when the Timer Node times out, we just added the call to make_rock()
func _on_Timer_timeout():
	if game_running == true:
		#print(game_running)
		get_node("Timer").set_wait_time(wait_time)
		for i in range(3):
			#print("making rock")
			make_rock()
	else:
		if rand_range(1,4) > 3:
			make_rock()
	
# create a make rock function that can be called by a timer node.
func make_rock():
	rock_count += 1
	var rock_instance = rock.instance()
	rock_instance.set_name("rock"+str(rock_count))
	add_child(rock_instance)
	rock_instance.set_owner(self)
	rock_instance.get_node("RigidBody2D").add_collision_exception_with(get_node("bottom_boundary"))
	rock_instance.get_node("RigidBody2D").add_collision_exception_with(get_node("top_boundary"))
	rock_instance.get_node("RigidBody2D").add_collision_exception_with(get_node("left_boundary"))
	rock_instance.get_node("RigidBody2D").add_collision_exception_with(get_node("right_boundary"))
	rock_instance.get_node("RigidBody2D").set_pos(Vector2(rand_range(110,1325),rand_range(-200,-250)))
	rock_instance.get_node("RigidBody2D").set_linear_velocity(rock_velocity + Vector2(rand_range(-90,90),0))
	if rand_range(0,2.1) < 1:
		rock_instance.get_node("RigidBody2D/AnimatedSprite/anim").set_speed(rand_range(.8,1))
	else:
		rock_instance.get_node("RigidBody2D/AnimatedSprite/anim").set_speed(rand_range(-.8,-1))
	rock_array.push_back("rock"+str(rock_count))


# Create a timer node to speed-up the game based on time.
var wait_time = 1.0
func _on_Timer_speed_up_game_timeout():
	# slowly increase the new rocks velocity
	rock_velocity += Vector2(0,20)
	# slowly decrease the timer value
	if wait_time > .2:
		wait_time -= .015
	
func increase_gui_score(points):
	get_node("/root/ship_root/gui_root/score_lbl").set_text("SCORE: " +str(points))
	
	
func end_game():
	game_running = false
	clear_lasers()
	clear_rocks()
	if score > high_score:
		high_score = score
		get_node("/root/ship_root/gui_root/game_over_lbl").set_text("GAME OVER!\n\n\nHigh Score:\n\n0000" + str(high_score) + "\n\n\nPress Enter to\n\nPlay Again!")
		
		
	get_node("/root/ship_root/KinematicBody2D/sound_root/SamplePlayer_thrust/").stop_all()
	
	get_node("/root/ship_root/gui_root/game_over_lbl").show()
	get_node("KinematicBody2D").set_pos(Vector2(740,2075))
	get_node("KinematicBody2D/Sprite/thrust_down_1").hide()
	get_node("KinematicBody2D/Sprite/thrust_down_2").hide()
	get_node("KinematicBody2D/Sprite/thrust_left").hide()
	get_node("KinematicBody2D/Sprite/thrust_right").hide()
	get_node("KinematicBody2D/Sprite/thrust_up").show()
	
func start_game():
	# code to reset the game here
	get_node("/root/ship_root/gui_root/main_menu_lbl").hide()
	get_node("/root/ship_root/gui_root/game_over_lbl").hide()
	
	rock_velocity = Vector2(0,90)
	wait_time = 1.0
	score = 0
	current_speed = Vector2(0,0)
	increase_gui_score(score)
	clear_rocks()
	clear_lasers()
	game_running = true
	pass
	
func clear_lasers():
	for laser in laser_array:                      
		if get_node(laser) != null:
			get_node(laser).queue_free()
	laser_array.clear()
	laser_count = 0
	
func clear_rocks():
	for rock in rock_array:
		if get_node(rock) !=    null:
			get_node(rock).queue_free()
	rock_array.clear()
	rock_count = 0
	