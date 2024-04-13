extends Node2D

var team = "light"
var type = "shooter"

func init(team, type, position):
	self.team = team
	self.type = type
	self.position = position
