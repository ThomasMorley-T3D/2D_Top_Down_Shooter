
extends Node2D

# load large rock scene
var large_rock = preload("res://rock/large_rock.scn")

# load medium rock scene
var medium_rock = preload("res://rock/medium_rock.scn")

# load small rock scene
var small_rock = preload("res://rock/small_rock.scn")

var the_rock = null
var rand_num = 0 

func _ready():
	# Initialization here grab a rock and set it's rotation and direction
	rand_num = rand_range(0,2.99)
	print(rand_num)
	if rand_num < 1:
		the_rock = small_rock.instance()
	elif rand_num > 2:
		the_rock = large_rock.instance()
	else:
		the_rock = medium_rock.instance()
	add_child(the_rock)


