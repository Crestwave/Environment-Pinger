name = "Environment Pinger [Fixed]"
description = "Ping various objects in the environment. See others' ping objects."
author = "sauktux"
version = "1.0.13".."v"
forumthread = ""
icon_atlas = "modicon.xml"
icon = "modicon.tex"
client_only_mod = true
all_clients_require_mod = false
server_only_mod = false
dont_starve_compatible = false
reign_of_giants_compatible = false
dst_compatible = true
api_version = 10

local function AddOption(name,label,hover,options,default)
    return  {
        name = name,
        label = label,
        hover = hover,
        options = options,
        default = default,
        }
end

local function FormatOption(description,data,hover)
   return {description = description, data = data, hover = hover} 
    
end

local function AddEmptySeperator(seperator)
    return AddOption("" , seperator , "" , FormatOption("",0) , 0)
end

local keys_opt = {
    FormatOption("None--",0),
    FormatOption("A",97),
    FormatOption("B",98),
    FormatOption("C",99),
    FormatOption("D",100),
    FormatOption("E",101),
    FormatOption("F",102),
    FormatOption("G",103),
    FormatOption("H",104),
    FormatOption("I",105),
    FormatOption("J",106),
    FormatOption("K",107),
    FormatOption("L",108),
    FormatOption("M",109),
    FormatOption("N",110),
    FormatOption("O",111),
    FormatOption("P",112),
    FormatOption("Q",113),
    FormatOption("R",114),
    FormatOption("S",115),
    FormatOption("T",116),
    FormatOption("U",117),
    FormatOption("V",118),
    FormatOption("W",119),
    FormatOption("X",120),
    FormatOption("Y",121),
    FormatOption("Z",122),
    FormatOption("--None--",0),
    FormatOption("Period",46),
    FormatOption("Slash",47),
    FormatOption("Semicolon",59),
    FormatOption("LeftBracket",91),
    FormatOption("RightBracket",93),
    FormatOption("F1",282),
    FormatOption("F2",283),
    FormatOption("F3",284),
    FormatOption("F4",285),
    FormatOption("F5",286),
    FormatOption("F6",287),
    FormatOption("F7",288),
    FormatOption("F8",289),
    FormatOption("F9",290),
    FormatOption("F10",291),
    FormatOption("F11",292),
    FormatOption("F12",293),
    FormatOption("Up",273),
    FormatOption("Down",274),
    FormatOption("Right",275),
    FormatOption("Left",276),
    FormatOption("PageUp",280),
    FormatOption("PageDown",281),
    FormatOption("Home",278),
    FormatOption("Insert",277),
    FormatOption("Delete",127),
    FormatOption("End",279),
    FormatOption("--None",0),
}

local bool_opt = {
    FormatOption("Disabled",false),
    FormatOption("Enabled",true),
}

local special_buttons = {
    FormatOption("None--",0),
    FormatOption("RShift",303),
    FormatOption("LShift",304),
    FormatOption("LCtrl",306),
    FormatOption("RCtrl",305),
    FormatOption("RAlt",307),
    FormatOption("LAlt",308),
    FormatOption("--None",0),
  }
  
local keys_and_special = {
    FormatOption("None--",0),
    FormatOption("A",97),
    FormatOption("B",98),
    FormatOption("C",99),
    FormatOption("D",100),
    FormatOption("E",101),
    FormatOption("F",102),
    FormatOption("G",103),
    FormatOption("H",104),
    FormatOption("I",105),
    FormatOption("J",106),
    FormatOption("K",107),
    FormatOption("L",108),
    FormatOption("M",109),
    FormatOption("N",110),
    FormatOption("O",111),
    FormatOption("P",112),
    FormatOption("Q",113),
    FormatOption("R",114),
    FormatOption("S",115),
    FormatOption("T",116),
    FormatOption("U",117),
    FormatOption("V",118),
    FormatOption("W",119),
    FormatOption("X",120),
    FormatOption("Y",121),
    FormatOption("Z",122),
    FormatOption("--None--",0),
    FormatOption("Period",46),
    FormatOption("Slash",47),
    FormatOption("Semicolon",59),
    FormatOption("LeftBracket",91),
    FormatOption("RightBracket",93),
    FormatOption("F1",282),
    FormatOption("F2",283),
    FormatOption("F3",284),
    FormatOption("F4",285),
    FormatOption("F5",286),
    FormatOption("F6",287),
    FormatOption("F7",288),
    FormatOption("F8",289),
    FormatOption("F9",290),
    FormatOption("F10",291),
    FormatOption("F11",292),
    FormatOption("F12",293),
    FormatOption("--None--",0),
    FormatOption("Up",273),
    FormatOption("Down",274),
    FormatOption("Right",275),
    FormatOption("Left",276),
    FormatOption("PageUp",280),
    FormatOption("PageDown",281),
    FormatOption("Home",278),
    FormatOption("Insert",277),
    FormatOption("Delete",127),
    FormatOption("End",279),
    FormatOption("RShift",303),
    FormatOption("LShift",304),
    FormatOption("LCtrl",306),
    FormatOption("RCtrl",305),
    FormatOption("RAlt",307),
    FormatOption("LAlt",308),
    FormatOption("--None",0), -- Presumably, if you're setting this to none, then you only want to "receive" pings.
}
local ping_times = {}
for i = 10,60,5 do
   ping_times[(i-5)/5] = FormatOption(i.."s",i)
end

configuration_options = {
	AddOption("ping_key","Ping Hold Key","The key that needs to be held to be able to ping.",keys_and_special,118),
    AddOption("whisper_key","Whisper Key","Hold this key to make your ping be whispered.",special_buttons,306),
    AddOption("pingsound","Ping Sound","Should a flare sound be played whenever a ping appears?",bool_opt,true),
    AddOption("pingtime","Ping Time","How long should the pings last locally?",ping_times,20),
    AddOption("encryptdata","Encrypt Data","Should the data part of the message be encrypted?",bool_opt,false),
}
