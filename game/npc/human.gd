extends Area2D

# Editor variables
export var speed = 1.0
export var flying_speed = 1.0
export var rot_speed = 0.0
export var planet_offset = 1.0

# Util
var initialized = false
onready var screen_size = get_viewport_rect().size

# Nodes
var collider
var collider_small
onready var sprite_idle = get_node('sprite_idle')
onready var sprite_flying = get_node('sprite_flying')
onready var anim = get_node('anim')

# State
var state = GROUNDED

enum State {
	GROUNDED,
	IN_HAND,
	FLYING
}

# State -> GROUNDED
var direction = 1
var angle = PI + PI / 2
var radius

# Other
var vel

var parent
var anker

func _ready():
	randomize()
	
	var random_direction = rand_range(0.5, 1.5)
	
	if int(random_direction):
		direction *= -1
	
	if not initialized:
		initialized = true
		
		# Load nodes
		collider = get_node('collider')
		collider_small = get_node('collider_small')
		
		add_to_group('humans')
		
		# Setup signals
		var giant = get_node('/root/main/giant')
		connect('input_event', giant, 'human_clicked', [self])
		
		parent = get_parent()
		var planet_sprite = parent.get_node('sprite')
		radius = (planet_sprite.get_item_rect().size.x * planet_sprite.get_scale().x) / 2
		
		# Setup collision
		remove_child(collider_small)
		
		# Other setup
		set_process(true)

func _process(delta):
	var pos = get_global_pos()
	
	if (pos.x < 0 or pos.x > screen_size.x \
	or pos.y < 0 or pos.y > screen_size.y) \
	and state == FLYING:
		queue_free()
	
	if state == GROUNDED:
		angle +=  speed * delta * direction
		
		set_pos((Vector2(cos(angle), sin(angle)) * radius * planet_offset))
		
		set_rot(0)
		set_rot(get_angle_to(parent.get_pos()))
	elif state == FLYING:
		rotate(rot_speed * delta)
		set_pos(get_pos() + vel * flying_speed * delta)

func _input_event(viewport, event, shape_idx):
	if state == GROUNDED \
	and not anim.is_playing():
		anim.play('wobble')

func grabbed(position):
	if state == FLYING:
		return false
	
	# Set state
	state = IN_HAND
	
	# Set visuals
	anim.stop(true)
	sprite_idle.hide()
	sprite_flying.show()
	
	# Setup collision
	add_child(collider_small)
	remove_child(collider)
	
	# Reset values and add to anker
	set_pos(Vector2(0, 0))
	set_rot(0)
	
	parent.remove_child(self)
	anker = position
	anker.add_child(self)
	parent = anker
	
	return true

func thrown(angle):
	state = FLYING
	set_pos(get_global_pos())
	set_rot(get_global_rot())
	
	# Remove from planet - add to scene
	var main = get_node('/root/main')
	get_parent().remove_child(self)
	main.add_child(self)
	
	vel = Vector2(cos(angle), sin(angle)) * speed

func _on_human_area_enter( area ):
	if area.is_in_group('planets'):
		call_deferred('reparent', area)

func reparent(area):
	state = GROUNDED
	
	# Set visuals
	sprite_idle.show()
	sprite_flying.hide()
	
	# Setup collision
	add_child(collider)
	remove_child(collider_small)
	
	# Set parent
	get_parent().remove_child(self)
	parent = area
	parent.add_child(self)
	
	var planet_sprite = parent.get_node('sprite')
	radius = (planet_sprite.get_item_rect().size.x * planet_sprite.get_scale().x) / 2
