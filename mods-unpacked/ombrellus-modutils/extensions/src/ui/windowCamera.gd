extends Camera2D

@onready var daddy:Node = get_parent()

func _process(delta):
	position = daddy.position
