class_name SettingLists
extends Resource

@export var suggestion_blacklist: Array[String] = [
	"11:8",
	"1470",
	"1478",
	"1502",
	"1545",
	"16:10",
	"16:9",
	"1763",
	"1768",
	"1775",
	"1789",
	"1798",
	"1808",
	"1814",
	"1829",
	"1837",
	"1842",
	"1850",
	"1860",
	"1862",
	"1863",
	"1867",
	"1868",
	"1873",
	"1875",
	"1878",
	"1885",
	"1886",
	"1894",
	"1896",
	"1900",
	"1905",
	"1907",
	"1911",
	"1912",
	"1913",
	"1914",
	"1916",
	"1919",
	"1920",
	"1921",
	"1924",
	"1926",
	"1930",
	"1933",
	"1936",
	"1937",
	"1940",
	"1942",
	"1944",
	"1956",
	"1958",
	"1960",
	"1966",
	"1967",
	"1968",
	"1970",
	"1971",
	"1972",
	"1973",
	"1975",
	"1976",
	"1977",
	"1978",
	"1979",
	"1980",
	"1981",
	"1982",
	"1984",
	"1985",
	"1986",
	"1987",
	"1988",
	"1989",
	"1990",
	"1991",
	"1992",
	"1993",
	"1994",
	"1995",
	"1996",
	"1997",
	"1998",
	"1999",
	"19th century",
	"1:1",
	"2000",
	"2001",
	"2002",
	"2003",
	"2004",
	"2005",
	"2006",
	"2007",
	"2008",
	"2009",
	"2010",
	"2011",
	"2012",
	"2013",
	"2014",
	"2015",
	"2016",
	"2019",
	"2020",
	"2021",
	"2023",
	"4:3",
	"4k",
	"4koma",
	"5:3",
	"5:4",
	"7:10",
	"7:5",
	"absurd res",
	"airbrush (artwork)",
	"album cover",
	"aliasing",
	"alpha channel",
	"anaglyph",
	"animated",
	"animated comic",
	"animated png",
	"arabic text",
	"artist name",
	"back cover",
	"black and blue",
	"black and grey",
	"black and red",
	"black and white",
	"black and white and red",
	"blue and white",
	"blue theme",
	"book cover",
	"braille text",
	"brown and white",
	"brown theme",
	"bust portrait",
	"cebuano text",
	"cel shading",
	"censored",
	"character name",
	"character request",
	"chinese text",
	"collaboration",
	"color contrast",
	"colored",
	"colored pencil (artwork)",
	"colored sketch",
	"colorful",
	"comic",
	"comic sans",
	"compression artifacts",
	"concept art",
	"cool colors",
	"cover",
	"cover art",
	"cover page",
	"crayon (artwork)",
	"credits",
	"cropped",
	"cross eye stereogram",
	"cyrillic text",
	"czech text",
	"danish text",
	"dark theme",
	"dated",
	"detailed",
	"digital drawing (artwork)",
	"digital media (artwork)",
	"digital painting (artwork)",
	"divinian text",
	"doujinshi",
	"dutch text",
	"end page",
	"english text",
	"engrish",
	"estonian text",
	"expression sheet",
	"filipino text",
	"finnish text",
	"first page",
	"flash",
	"flash game",
	"flat colors",
	"frame by frame",
	"french text",
	"full-length portrait",
	"german text",
	"greek text",
	"green and white",
	"green theme",
	"grey theme",
	"greyscale",
	"guide lines",
	"half-length portrait",
	"hard translated",
	"headshot portrait",
	"hebrew text",
	"hi res",
	"high contrast",
	"hungarian text",
	"icon",
	"image macro",
	"indonesian text",
	"interactive",
	"interactive comic",
	"irish text",
	"italian text",
	"japanese text",
	"korean text",
	"latin text",
	"latvian text",
	"lighting",
	"line art",
	"lineless",
	"lol comments",
	"long image",
	"loop",
	"low res",
	"luxembourgish text",
	"magazine cover",
	"malaysian text",
	"manga",
	"marker (artwork)",
	"md5 mismatch",
	"meme",
	"mixed media",
	"model sheet",
	"monochrome",
	"mosaic censorship",
	"multiple images",
	"multiple scenes",
	"multiple versions",
	"neon colors",
	"no sound",
	"norwegian text",
	"nude edit",
	"official art",
	"one page comic",
	"orange and white",
	"orange theme",
	"painting (artwork)",
	"partially colored",
	"partially translated",
	"pastel (artwork)",
	"pen (artwork)",
	"pencil (artwork)",
	"photo manipulation",
	"photography (artwork)",
	"photomorph",
	"picture in picture",
	"pink and white",
	"pink theme",
	"pixel (artwork)",
	"pixel animation",
	"polish text",
	"portrait",
	"portuguese text",
	"purple and white",
	"purple theme",
	"red and white",
	"red theme",
	"restricted palette",
	"russian text",
	"sepia",
	"sequence",
	"shaded",
	"shopped",
	"signature",
	"simple shading",
	"sketch",
	"sketch page",
	"slideshow",
	"soft shading",
	"sound",
	"source request",
	"spanish text",
	"spot color",
	"stereogram",
	"story",
	"story at source",
	"story in description",
	"superabsurd res",
	"swedish text",
	"tag panic",
	"tagme",
	"tall image",
	"tan theme",
	"tengwar text",
	"text game",
	"thai text",
	"three-quarter portrait",
	"thumbnail",
	"traced",
	"traditional media (artwork)",
	"translated",
	"translation request",
	"turkish text",
	"ukrainian text",
	"uncensor request",
	"uncensored",
	"unfinished",
	"unknown language",
	"unknown text",
	"unusual coloring",
	"upscale",
	"url",
	"vietnamese text",
	"voice acted",
	"wallpaper",
	"warm colors",
	"watercolor (artwork)",
	"watermark",
	"webm",
	"welsh text",
	"widescreen",
	"wiggle stereogram",
	"yellow and white",
	"yellow theme",
	]

@export var invalid_tags: Array[String] = [
	"2 armed",
	"2 arms",
	"2 legged",
	"2 legs",
	"anatomically incorrect",
	"animal",
	"animals",
	"anime",
	"animeart",
	"ankles",
	"arm",
	"arm pits",
	"armpit",
	"armpits",
	"arms",
	"art trade",
	"artwork",
	"ass worship",
	"attractive",
	"belly button swirl",
	"bimbo",
	"bishoujo",
	"bliss",
	"boyfriend",
	"boypussy",
	"breeding",
	"bussy",
	"bustyboi",
	"butt slut",
	"calves",
	"change",
	"changed",
	"character from animated feature",
	"character from animated feature film",
	"cheeks",
	"clean",
	"closed species",
	"cock sleeve",
	"cocksleeve",
	"commission",
	"control",
	"cruel",
	"cute",
	"cute face",
	"digital sports",
	"display",
	"ear",
	"ears",
	"ecchi",
	"elbow",
	"eminent anal vore",
	"erotic",
	"evil",
	"exotic",
	"expression",
	"extreme",
	"eyes",
	"eyes opened",
	"eyes opening",
	"faces",
	"fan art",
	"fan service",
	"fan-art",
	"fanart",
	"fanfic art",
	"fanservice",
	"fat ass",
	"fauna",
	"female human",
	"fighter",
	"first time",
	"flank",
	"friendship",
	"furries",
	"furry art",
	"fursona",
	"fursonas",
	"gentle",
	"gift art",
	"giftart",
	"girlfriend",
	"girlfriends",
	"grab",
	"graphic",
	"graphics",
	"gripping",
	"hand",
	"hard",
	"hardcore",
	"head",
	"headcanon",
	"hear",
	"hentai",
	"hideous",
	"homoerotic",
	"horror",
	"huge",
	"hunk",
	"hunky",
	"implied",
	"implied anal",
	"implied bestiality",
	"implied death",
	"implied dickgirl",
	"implied digestion",
	"implied fellatio",
	"implied masturbation",
	"implied penetration",
	"implied sex",
	"implied vore",
	"inspecting",
	"inter racial",
	"interracial",
	"juicy",
	"kawaii",
	"kemono.party",
	"kinky",
	"knee",
	"knees",
	"large",
	"leg",
	"little",
	"monster cock",
	"motion",
	"mouth",
	"murr",
	"mutant",
	"navel domination",
	"neuter",
	"no anus",
	"no balls",
	"no bra",
	"no feet",
	"no humans",
	"no iris",
	"no nipples",
	"no pussy",
	"no visible genitalia",
	"non canon",
	"non english",
	"non-canon",
	"nonhuman",
	"nostalgia",
	"nostril",
	"nostrils",
	"offscreen masturbation",
	"oviparous",
	"panel",
	"panels",
	"pedophile",
	"people",
	"person",
	"pleasing",
	"pleasure",
	"pleasuring",
	"plot",
	"pokesex",
	"ponyart",
	"r34",
	"related",
	"repost",
	"revolting",
	"ripped",
	"round",
	"ruined orgasm",
	"rule 34",
	"rule-34",
	"rule34",
	"same species",
	"sexual predator",
	"sexy",
	"sharp",
	"shoulders",
	"slut",
	"slutty",
	"small pred",
	"smooth",
	"soft",
	"softcore",
	"stud",
	"swap",
	"swapped",
	"sweet",
	"tg",
	"tight",
	"touch",
	"touching",
	"tough",
	"tranny",
	"trans man penetration",
	"two armed",
	"two arms",
	"two legged",
	"two legs",
	"ugly",
	"unhappy",
	"unwanted",
	"well endowed",
	"white sclera",
	"whore",
	"wild",
	"willing",
	"wingless",
]

@export var constant_tags: Array[String] = []

@export var loader_blacklist: Array[String] = []

@export var suggestion_review_blacklist: Array[String] = ["comic"]
@export var samples_blacklist: Array[String] = ["comic"]

@export var shortcuts: Dictionary = {}


static func load_database() -> SettingLists:
	if ResourceLoader.exists("user://settings_lists.tres"):
		return ResourceLoader.load("user://settings_lists.tres")
	else:
		return SettingLists.new()


func save() -> void:
	ResourceSaver.save(self, "user://settings_lists.tres")


func remove_from_suggestion_review_blacklist(tag_to_remove: String) -> void:
	if not suggestion_review_blacklist.has(tag_to_remove):
		return
	
	if suggestion_review_blacklist.size() == 1:
		suggestion_review_blacklist.clear()
		return
	
	var target_index: int = suggestion_review_blacklist.find(tag_to_remove)
	suggestion_review_blacklist[target_index] = suggestion_review_blacklist.back()
	suggestion_review_blacklist.resize(suggestion_review_blacklist.size() - 1)


func add_to_blacklist(tag_to_add: String) -> void:
	suggestion_blacklist.append(tag_to_add)


func remove_from_sample_blacklist(tag_to_remove: String) -> void:
	if not samples_blacklist.has(tag_to_remove):
		return
	
	if samples_blacklist.size() == 1:
		samples_blacklist.clear()
		return
	
	var target_index: int = samples_blacklist.find(tag_to_remove)
	samples_blacklist[target_index] = samples_blacklist.back()
	samples_blacklist.resize(samples_blacklist.size() - 1)


func remove_from_blacklist(tag_to_remove: String) -> void:
	var target_index = suggestion_blacklist.find(tag_to_remove)
	if target_index == -1:
		return
	
	suggestion_blacklist[target_index] = suggestion_blacklist.back()
	suggestion_blacklist.resize(suggestion_blacklist.size() - 1)


func remove_from_invalids(tag_to_remove: String) -> void:
	var target_index = invalid_tags.find(tag_to_remove)
	if target_index == -1:
		return
	
	invalid_tags[target_index] = suggestion_blacklist.back()
	suggestion_blacklist.resize(suggestion_blacklist.size() - 1)


func remove_from_constant_tags(tag_to_remove: String) -> void:
	var target_index: int = constant_tags.find(tag_to_remove)
	
	if target_index == -1:
		return
	
	constant_tags[target_index] = constant_tags.back()
	constant_tags.resize(constant_tags.size() - 1)


