extends Node

var ship_grid

var fired_shots = 0
var missed_shots = 0
var hit_shots = 0
var time_spent = 0
var tiles_left = 0
var enemy_tiles_left = 0


func reset():
	fired_shots = 0
	missed_shots = 0
	hit_shots = 0
	time_spent = 0
	tiles_left = 0
	enemy_tiles_left = 0
