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
        "New point of interest added to the map!"
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
        -- Lists are nice when they are sorted even a bit.
        -- Mobs and some interactable entities go here:
        mole = {
            "You shouldn't eat precious minerals, %S, it will get you killed.",
        },
        monkey = {
         "%S! Smells like poop.",
        },
        molehill = {
            "%S here! I bet it's hiding precious minerals and trinkets.",
        },
        lureplant = {
            "Be careful of the %S here. Don't let the food fool you!",
        },
        hound = {
            "%S, a minion of evil here!",
        },
        firehound = {
            "Watch the fire, %S here!",
        },
        icehound = {
            "Teeths of frost! %S here.",
        },
        lavae = {
            "Stay back from that %S, it's unstable!",
        },
        red_mushroom = {
            "Mushroom.",
        },
        blue_mushroom = {
            "Mushroom.",
        },
        green_mushroom = {
            "Mushroom.",
        },
        -- Characters go here:
        wilson = {
            "I see %S looking for a base.", -- Yes, don't judge me.
            "Mad scientist %S is here.",
        },
        willow = {
            "The master of flames %S is here!",
        },
        wolfgang = {
            "The muscleman %S is here.",
        },
        wendy = {
            "The ectoherbologist %S, I wonder if she has any potions.",
        },
        wx78 = {
            "The robot %S, are your gears running well?",
        },
        wickerbottom = {
            "Librarian %S is here!",   
        },
        woodie = {
            "I see lumberjack %S.",  
        },
        wes = {
            "As silent as he is deadly, %S is here."  
        },
        waxwell = {
            "Shadow pupeteer %S is here!",   
        },
        wathgrithr = {
            "The mighty warrior %S is here!",
        },
        warly = {
            "The master chef %S is here!",
        },
        webber = {
            "The spider child %S is here!",  
        },
        wormwood = {
            "The plant friend %S is here!",   
        },
        winona = {
            "Factory worker %S is here!",  
        },
        wortox = {
            "The mischievous imp %S is travelling here!",  
        },
        wurt = {
            "Mermfolk %S is here.",  
        },
        walter = {
            "The fearless Pinetree Pioneer %S is here.",  
        },
        -- Items go here:
        goldnugget = {
          "%S here. We're rich!",  
        },
    },
}


return strings