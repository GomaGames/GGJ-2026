extends Node


class_name Utils

static var costumeList = ["DRAGON","KING","KNIGHT","VISIER","WIZARD","PRINCESS"]


static func GetCostumeString(id) -> String:
  return costumeList[id-1]
