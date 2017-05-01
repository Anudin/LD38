extends Node2D

onready var timer = get_node('cooldown')

# State
enum State {
	IDLE,
	GRABBED
}

var state = IDLE

export var speed = 1.0
export var arm_range = 1

var planet setget set_planet
var radius
var angle = PI + PI / 2

func _ready():
	# Connect to click events of planets
	var planets = get_tree().get_nodes_in_group('planets')
	
	for i in range(planets.size()):
		var planet = planets[i]
		planet.connect('input_event', self, 'planet_clicked', [planet])
	
	var earth = get_node('/root/main/earth')
	earth.connect('input_event', self, 'planet_clicked', [earth])
	
	# Other setup
	set_process_unhandled_input(true)
	set_process(true)

func _process(delta):
	if planet:
		var dir = Input.is_action_pressed('right') - Input.is_action_pressed('left')
		angle +=  dir * speed * delta
		
		set_pos(planet.get_pos() + (Vector2(cos(angle), sin(angle)) * radius))
		
		set_rot(0)
		set_rot(get_angle_to(planet.get_pos()))

func _unhandled_input(event):
	if state == GRABBED \
	and event.is_action_pressed('click'):
		state = IDLE
		timer.set_wait_time(.1)
		timer.start()
		get_node('hand_slot').get_child(0).thrown(angle)

func set_planet(value):
	planet = value
	var planet_sprite = planet.get_node('sprite')
	radius = (planet_sprite.get_item_rect().size.x * planet_sprite.get_scale().x) / 2

# Change planet
func planet_clicked(viewport, event, shape_idx, planet):
	if state != GRABBED \
	and timer.get_time_left() == 0 \
	and event.is_action_pressed('click'):
		self.planet = planet

# Grap human
func human_clicked(viewport, event, shape_idx, human):
	if state != GRABBED \
	and event.is_action_pressed('click') \
	and get_pos().distance_squared_to(human.get_global_pos()) < arm_range:
		if human.grabbed(get_node('hand_slot')):
			state = GRABBED
