extends TitleWindow

@onready var focus_dummy = $Control/focusDummy
@onready var button = %Button
var splitWindows:Array

func _ready():
	button.click.connect(func():
		Global.title.switch(self)
		Global.title.split(self, splitWindows)
	)
	Utils.runLater(100, func():
		#button.grab_focus()
		focus_dummy.focus_mode = Control.FOCUS_ALL
		focus_dummy.grab_focus()
		#Focus.focus(button)
	)
	
