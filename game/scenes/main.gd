# You can do better... points: XYZ

# Make game fun. (Human instant damage, maximum humans per planet 3-5, moving planets)
# max damage?

# Flicker on planet enter
# Replace get_node() repeatedly called
# Review radius calculation

# Code clean up

# Implement:
# Path following

# Refactor radial movement component?

extends Node

# Scenes
onready var giant = preload('res://player/giant.tscn')
onready var human = preload('res://npc/human.tscn')

# Nodes
onready var score_label = get_node('hud/score_label')

# Other
var score = 1

func _ready():
	setup_window()
	
	# Init player
	var g = giant.instance()
	g.planet = get_node('earth')
	add_child(g)
	
	# Init human(s)
	var h = human.instance()
	get_node('earth').add_child(h)
	
	# Other setup
	set_process(true)
	set_process_input(true)

func setup_window():
	var screen_size = OS.get_screen_size(0)
	var window_size = Vector2(1440, 768)
	
	if screen_size.x < 1440:
		window_size = Vector2(screen_size.x, screen_size.x * (9/16))
	
	# Setup window
	OS.set_window_title('A giant called Frederick.')
	OS.set_window_size(window_size)
	
	# Center window
	OS.set_window_position(screen_size / 2 - window_size / 2)

func _process(delta):
	# You lost.
	if (get_tree().get_nodes_in_group('humans').size() == 0 \
	or get_tree().get_nodes_in_group('planets').size() == 0):
		get_node('hud/lost_notification').show()
		get_tree().set_pause(true)
		
		#for child in get_children():
		#	child.set_process(false)

func _on_human_spawned():
	if score < get_tree().get_nodes_in_group('humans').size():
		score += 1
		score_label.set_text('Score: ' + str(score))
