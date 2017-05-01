extends Area2D

signal human_spawned

export var max_humans = 3
export var damage_factor = 0.5
export var healing_factor = 1.0

var damage = 0.0
var humans = 0

var is_dead = false

onready var human = preload('res://npc/human.tscn')

onready var sprite = get_node('sprite')
var radius
onready var dead = get_node('dead')
onready var timer = get_node('timer')
onready var label = get_node('damage_label')

onready var tree_sprite = preload('res://scenes/tree.tscn')
var trees = []

func _ready():
	randomize()
	connect('human_spawned', get_node('/root/main'), '_on_human_spawned')
	
	# Spawn trees
	radius = (sprite.get_item_rect().size.x * sprite.get_scale().x) / 2
	
	for ang in range(0, 360, 360/5):
		var tree = tree_sprite.instance()
		
		ang += rand_range(-20, 20)
		
		var off = rand_range(-5, 5)
		tree.set_pos(Vector2(cos(deg2rad(ang)) * (radius + off), sin(deg2rad(ang)) * (radius + off)))
		tree.set_z(rand_range(0,3))
		tree.set_rotd(270 - ang)
		
		trees.append(tree)
		add_child(tree)
	
	# Human population timer
	timer.connect('timeout', self, '_on_timer_timeout')
	
	# Random sprite rotation
	sprite.set_rot(rand_range(-PI, PI))
	
	set_process(true)

func _on_timer_timeout():
	if humans < max_humans:
		var h = human.instance()
		add_child(h)
		emit_signal('human_spawned')

func _process(delta):
	var trees_size = trees.size()
	var sep = 100 / trees_size
	
	for i in range(trees_size):
		var tree = trees[i]
		
		if(i * sep < damage):
			tree.hide()
		else:
			tree.show()
	
	if humans:
		if not timer.is_active():
			timer.set_active(true)
			timer.start()
	else:
		timer.set_active(false)
	
	if not is_dead \
	and humans == 0:
		damage -= delta * healing_factor
	else:
		var damage_p_tick = humans * delta * damage_factor
		print(damage_p_tick * 60)
		damage_p_tick = clamp(damage_p_tick, 0, 3)
		damage += damage_p_tick
	
	damage = clamp(damage, 0, 100)
	humans = 0
	
	# Count humans on planet
	for child in get_children():
		if child.is_in_group('humans'):
			humans += 1
	
	label.set_text(str(int(damage)) + '%')
	
	# Destroy planet
	if damage == 100:
		is_dead = true
		sprite.hide()
		dead.show()
		label.hide()
		remove_from_group('planets')
		set_process(false)
		
		for child in get_children():
			if child.is_in_group('humans'):
				humans -= 1
				child.queue_free()
