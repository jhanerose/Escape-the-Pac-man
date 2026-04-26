extends CanvasLayer

func _ready():
	# This tells the global GameManager: "Hey, use THIS label for messages!"
	GameManager.announcement_label = $Label
	
	# Make sure it's hidden and centered to start
	$Label.visible = false
	$Label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	print("UI: Handshake successful! Label linked to GameManager.")
