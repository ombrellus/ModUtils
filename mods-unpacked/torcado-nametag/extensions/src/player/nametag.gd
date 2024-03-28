extends Control
@onready var label = %Label

@onready var Global = get_node("/root/ModLoader/torcado-nametag/Global")

func _ready() -> void:
	Global.apply_config.connect(apply_config)
	Global.nametag_label = label
	Global.nametag_created.emit(label)
	
	Global.disable.connect(_disable)
	
	var config = ModLoaderConfig.get_current_config("torcado-nametag")
	apply_config(config)


func apply_config(config: ModConfig) -> void:
	label.text = config.data.name

func _disable():
	queue_free()
