extends Control

var main_scene = preload('res://scenes/main.tscn')

func _ready():
	set_process_input(true)

func _input(event):
	if get_tree().is_paused() \
		and event.is_action_pressed('restart'):
			get_tree().set_pause(false)
				
			var root = get_node('/root')
			var main_node = get_node('/root/main')
			
			main_node.queue_free()
			root.remove_child(main_node)
			root.add_child(main_scene.instance())
