extends Node
@onready var life_label = $HBoxContainer/Label 

# Called when the node enters the scene tree for the first time.
func _ready():
	GameManager.life_lost.connect(update_lives)
	GameManager.score_updated.connect(update_score)
	
	# Set initial values after scene reload
	update_lives(GameManager.current_lives)
	update_score(GameManager.total_pellets_collected)

func update_lives(lives):
	$HBoxContainer/Label.text = "LIVES: " + str(lives)

func update_score(score):
	%ScoreLabel.text = "SCORE: " + str(score)
