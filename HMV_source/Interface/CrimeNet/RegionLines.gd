tool
extends Node2D


func _ready():
	var font:DynamicFont = DynamicFont.new()
	font.font_data = load("res://DINEngschrift.ttf")
	font.size = 64
	
	for region in regions.values():
		var line2d:Line2D = Line2D.new()
		line2d.texture = load("res://Interface/CrimeNet/Textures/cn_map_line.png")
		line2d.texture_mode = Line2D.LINE_TEXTURE_STRETCH
		line2d.width = 8
		line2d.default_color = Color( 0.498039, 0.615686, 0.713726, 1 )
		for i in region[0].size():
			var pointpos = Vector2(region[0][i], region[1][i])
			line2d.add_point( pointpos )
		if region.has("closed") and region["closed"]:
			line2d.add_point( line2d.points[0] )
		add_child(line2d)
		
		if region.has("text"):
			var reg_label:Label = Label.new()
			reg_label.grow_horizontal = Control.GROW_DIRECTION_BOTH
			reg_label.grow_vertical = Control.GROW_DIRECTION_BOTH
			reg_label.set("custom_fonts/font", font)
			reg_label.self_modulate = Color(1.0, 1.0, 1.0, 0.33)
			reg_label.text = region["text"]["title_id"]
			reg_label.rect_position = Vector2(region["text"]["x"], region["text"]["y"])
			add_child(reg_label)


const regions = {
	0:{
		0:[
			-10,
			270,
			293,
			252,
			271,
			337,
			341,
			372,
			372,
			475,
			475,
			491,
			491,
			504,
			503,
			524,
			536,
			536,
			542,
			542,
			555,
			555,
			598,
			598,
			638,
			638,
			657,
			688,
			686,
			691,
			701,
			698,
			687,
			650,
			634,
			602,
			609,
			580,
			576,
			576,
			567,
			559,
			558,
			542,
			543,
			512,
			512,
			503,
			381,
			377,
			348,
			315,
			315,
			290,
			290,
			259,
			259,
			237,
			237,
			261,
			261,
			257,
			224,
			221,
			187,
			182,
			163,
			163,
			147,
			147,
			133,
			133,
			102,
			102,
			-10
		],
		1:[
			-10,
			-10,
			28,
			73,
			122,
			123,
			132,
			141,
			145,
			172,
			216,
			215,
			180,
			179,
			229,
			228,
			244,
			253,
			253,
			248,
			247,
			241,
			241,
			219,
			219,
			209,
			208,
			234,
			241,
			242,
			262,
			270,
			277,
			276,
			279,
			296,
			300,
			362,
			361,
			408,
			416,
			417,
			430,
			430,
			477,
			477,
			514,
			523,
			523,
			514,
			514,
			501,
			493,
			484,
			469,
			469,
			465,
			465,
			439,
			440,
			434,
			430,
			429,
			433,
			433,
			438,
			438,
			423,
			423,
			435,
			435,
			423,
			423,
			412,
			412
		],
		closed = true,
		text = {
			title_id = "GEORGETOWN",
			x = 348,
			y = 310
		}
	},
	1:{
		0:[
			340,
			350,
			350,
			373,
			373,
			368,
			368,
			358,
			358,
			351,
			351,
			340
		],
		1:[
			103,
			103,
			106,
			106,
			116,
			116,
			123,
			123,
			116,
			116,
			122,
			121
		],
		closed = true
	},
	2:{
		0:[
			564,
			576,
			576,
			564
		],
		1:[
			189,
			189,
			208,
			208
		],
		closed = true
	},
	3:{
		0:[
			147,
			168,
			164,
			144
		],
		1:[
			444,
			451,
			463,
			457
		],
		closed = true
	},
	4:{
		0:[
			168,
			185,
			181,
			166
		],
		1:[
			463,
			468,
			478,
			473
		],
		closed = true
	},
	5:{
		0:[
			371,
			417,
			417,
			414,
			371
		],
		1:[
			534,
			534,
			554,
			557,
			538
		],
		closed = true
	},
	6:{
		0:[
			422,
			509,
			509,
			500,
			500,
			477,
			477,
			466,
			457,
			457,
			447,
			422
		],
		1:[
			534,
			534,
			548,
			559,
			585,
			585,
			575,
			581,
			581,
			573,
			573,
			557
		],
		closed = true
	},
	7:{
		0:[
			519,
			530,
			517,
			528,
			522,
			540,
			538,
			544,
			549,
			561,
			565,
			571,
			566,
			574,
			579,
			609,
			613,
			630,
			628,
			644,
			641,
			662,
			665,
			703,
			696,
			721,
			721,
			756,
			756,
			767,
			767,
			736,
			709,
			701,
			651,
			651,
			640,
			623,
			634,
			608,
			591,
			581,
			599,
			599,
			551,
			541,
			598,
			598,
			640,
			735,
			735,
			751,
			760,
			766,
			771,
			831,
			831,
			882,
			882,
			922,
			922,
			976,
			976,
			1031,
			1036,
			1019,
			1020,
			994,
			1063,
			1063,
			1068,
			1098,
			1104,
			1113,
			1123,
			1132,
			1175,
			1175,
			1184,
			1184,
			1171,
			1171,
			1161,
			1161,
			1169,
			1169,
			1185,
			1185,
			1168,
			1168,
			1175,
			1175,
			1193,
			1193,
			1175,
			1175,
			1170,
			1170,
			1190,
			1190,
			1171,
			1171
		],
		1:[
			-10,
			13,
			23,
			34,
			42,
			57,
			61,
			68,
			63,
			75,
			69,
			74,
			79,
			87,
			82,
			113,
			110,
			128,
			131,
			144,
			148,
			169,
			165,
			199,
			207,
			226,
			239,
			258,
			276,
			284,
			305,
			341,
			340,
			331,
			331,
			343,
			338,
			364,
			369,
			428,
			428,
			452,
			460,
			514,
			514,
			540,
			540,
			586,
			636,
			636,
			552,
			549,
			545,
			539,
			529,
			529,
			533,
			533,
			530,
			530,
			537,
			537,
			530,
			530,
			521,
			483,
			480,
			416,
			382,
			345,
			340,
			353,
			348,
			346,
			346,
			350,
			328,
			297,
			297,
			269,
			269,
			247,
			247,
			222,
			222,
			182,
			182,
			170,
			170,
			116,
			116,
			111,
			111,
			85,
			85,
			68,
			68,
			60,
			60,
			31,
			31,
			-10
		],
		closed = true,
		text = {
			title_id = "WEST END",
			x = 789,
			y = 418
		}
	},
	8:{
		0:[
			1031,
			1052,
			1039,
			1039,
			1045,
			1045,
			1039,
			1039,
			1000,
			990,
			972,
			972,
			927,
			908,
			901,
			882,
			882,
			722,
			693,
			693,
			686,
			685,
			676,
			676,
			688,
			693,
			730,
			730,
			679,
			670,
			664,
			664,
			667,
			667,
			673,
			669,
			674,
			652,
			652
		],
		1:[
			530,
			574,
			575,
			616,
			616,
			667,
			667,
			893,
			893,
			883,
			883,
			855,
			855,
			842,
			853,
			853,
			906,
			906,
			874,
			816,
			816,
			804,
			804,
			785,
			785,
			774,
			774,
			759,
			759,
			754,
			745,
			734,
			726,
			691,
			686,
			683,
			677,
			657,
			636
		],
		closed = false,
		text = {
			title_id = "FOGGY BOTTOM",
			x = 858,
			y = 704
		}
	},
	9:{
		0:[
			512,
			529,
			516,
			519,
			513,
			495,
			498,
			501,
			504,
			500
		],
		1:[
			597,
			616,
			627,
			630,
			634,
			609,
			607,
			611,
			609,
			604
		],
		closed = true
	},
	10:{
		0:[
			559,
			569,
			571,
			639,
			631,
			647,
			616,
			616,
			610,
			610,
			601,
			598,
			589,
			580,
			569,
			561,
			557,
			557,
			584,
			584,
			580,
			591,
			589,
			580,
			570,
			564,
			568,
			563,
			558,
			561,
			552,
			546,
			550,
			549
		],
		1:[
			601,
			611,
			609,
			666,
			679,
			692,
			732,
			792,
			792,
			814,
			814,
			822,
			831,
			833,
			831,
			825,
			815,
			721,
			721,
			710,
			706,
			697,
			688,
			686,
			693,
			683,
			676,
			658,
			650,
			646,
			619,
			614,
			610,
			608
		],
		closed = true
	},
	11:{
		0:[
			2047,
			1972,
			1879,
			1879,
			1735,
			1677,
			1677,
			1683,
			1625,
			1619,
			1624,
			1620,
			1641,
			1641,
			1572,
			1571,
			1558,
			1558,
			1547,
			1547,
			1523,
			1523,
			1462,
			1462,
			1450,
			1450,
			1422,
			1402,
			1402,
			1356,
			1356,
			1316,
			1316,
			1308,
			1308,
			1279,
			1279,
			1245,
			1245,
			1200,
			1200,
			1039
		],
		1:[
			278,
			311,
			311,
			352,
			416,
			416,
			429,
			440,
			468,
			461,
			458,
			451,
			442,
			420,
			420,
			470,
			470,
			467,
			467,
			469,
			469,
			518,
			518,
			532,
			532,
			547,
			560,
			560,
			570,
			569,
			591,
			610,
			604,
			604,
			614,
			628,
			614,
			614,
			644,
			665,
			608,
			608
		],
		closed = false,
		text = {
			title_id = "SHAW",
			x = 1426,
			y = 310
		}
	},
	12:{
		0:[
			1200,
			1206,
			1206,
			1201,
			1201,
			1251,
			1251,
			1201,
			1201,
			1205,
			1254,
			1254,
			1285,
			1285,
			1308,
			1308,
			1372,
			1372,
			1388,
			1388,
			1411,
			1411,
			1462,
			1462,
			1523,
			1523,
			1538,
			1538,
			1528,
			1527,
			1709,
			1709,
			1760,
			1880,
			1880,
			2047
		],
		1:[
			665,
			669,
			688,
			688,
			741,
			760,
			787,
			787,
			898,
			902,
			902,
			896,
			896,
			902,
			902,
			896,
			896,
			903,
			903,
			896,
			896,
			898,
			898,
			889,
			889,
			901,
			901,
			920,
			920,
			953,
			953,
			902,
			902,
			798,
			609,
			609
		],
		closed = false,
		text = {
			title_id = "DOWNTOWN",
			x = 1469,
			y = 720
		}
	}
}
