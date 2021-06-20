-- Automatically subbed strings:
-- that/those
-- %S
-- a/an
-- this/these
local strings = {
    ground = {
        "Look here!",
        "Look at this spot!",
        "Look over here!",
        "Look!",
        "See here.",
        "Here!",
    },
    
    item = {
        "Look at that/those %S there!",
        "Look at this/these %S!",
        "See the %S here!",
        "There's a/an %S here!",
        "%S here!",
        "%S!",
    },
    
    structure = {
        "Cool looking %S here!",
        "Found a/an %S!",
        "See here for a/an %S!",
        "Look here, it's a/an %S.",
    },
    
    mob = {
        "This %S seems to be alive!",
        "Watch out for the %S!",
        "I spy with my eye a/an %S!",
        "Be careful of the %S here!",
        "Look at the %S!",
        "Hmm, there's a/an %S here.",
        "There is a/an %S here!",
    },
    
    
    boss = {
        "The %S seems dangerous here!",
        "The %S boss is here!",
        "Look at that huge %S!",
        "The %S might be able to digest me!",
        "Danger! There's a/an %S here!",
        "Watch out, %S is here!",
    },
    
    map = {
        "Check your maps here!",
        "Look at the map position!",
        "Look at your maps!",
    },
    
    other = {
        "Woah, look at this %S!",
        "What a glamorous %S.",
        "Quite a fascinating %S here.",
        "Behold it's a/an... %S.",
        "Is this a/an %S?", -- *points to butterfly*
        "Huh, it's a/an %S.",
    },
    
    generic = {
        "Look!",
        "See this!",
        "Here!",
    },
    
    custom = {
        mole = {
            "You shouldn't eat precious minerals, %S, it will get you killed.",
        },
        molehill = {
            "%S here! I bet it's hiding precious minerals and trinkets.",
        },
        warly = {
            "The master chef %S is here!",
        },
        wathgrithr = {
            "The mighty warrior %S is here!",
        },
    },
}


return strings