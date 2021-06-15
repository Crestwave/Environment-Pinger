local pingstrings = require "environmentpinger/pingstrings"
local Image = require "widgets/image"
local PingImageManager = require "widgets/pingimagemanager"

local EnvironmentPinger = Class(function(self,inst)
        self.owner = inst
    end)


function EnvironmentPinger:OnMessageReceived(chatqueue,name,prefab,message,colour,whisper,profileflair)
    if string.match(message,STRINGS.LMB.." .+\n{[-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+} %S+") then
       local pos_str = string.match(message,STRINGS.LMB.." .+\n{([-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+)} %S+")
       local pos_x = tonumber(string.match(pos_str,"(.+),"))
       local pos_z = tonumber(string.match(pos_str,",(.+)"))
       local ping_type = string.match(message,STRINGS.LMB.." .+\n{[-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+} (%S+)")
       print(pos_x,pos_z,ping_type)
       if EnvironmentPinger:IsValidPingType(ping_type) then
           self:AddIndicator(name,ping_type,{x = pos_x,y = 0,z = pos_z},colour)
       end
    end
end

function EnvironmentPinger:AddIndicator(source,ping_type,pos,colour)
    if not self.pingimagemanager and self.owner.HUD then
        self.pingimagemanager = self.owner.HUD:AddChild(PingImageManager(self.owner))
    end
    self.pingimagemanager:AddIndicator(source,ping_type,pos,colour)
end

function EnvironmentPinger:IsOnFire(object)
    return object:HasTag("fire")
end

function EnvironmentPinger:IsSmoldering(object)
    return object:HasTag("smolder")
end

function EnvironmentPinger:IsBurnt(object)
    return object:HasTag("burnt")
end

function EnvironmentPinger:HandleBaseMessageInformation(act)
    local target = act.target
    local pos = target and target:GetPosition() or TheInput:GetWorldPosition()
    local pos_message = pos and "\n{"..string.format("%.3f",pos.x)..","..string.format("%.3f",pos.z).."}" or ""
    local message = STRINGS.LMB.." "
    if target then
        local display_adjective_fn = target and target.displayadjectivefn
        local object_name = display_adjective_fn ~= nil and display_adjective_fn().." "..target:GetDisplayName() or target:GetDisplayName()
        if self:IsOnFire(target) then
            object_name = "Burning "..object_name
        elseif self:IsBurnt(target) then
            object_name = "Burnt "..object_name
        end
        local stackable = target.replica.stackable
        local stack_size = stackable and stackable:StackSize() or 1
        local cant_be_pluralized = string.match(object_name,"%a+(s)$") -- Last words letter is 's'
        local item_name_many = cant_be_pluralized and object_name or object_name.."s"
        local article = string.match(object_name,"^[AEIOUaeiou]") and "an" or "a"
        return message,pos_message,object_name,stack_size,item_name_many,article
    end
    return message,pos_message
end

local ping_types = {
    ["ground"] = function(act)
        local message,pos_message = EnvironmentPinger:HandleBaseMessageInformation(act)
        local ground_messages = pingstrings.ground
        local r_message = ground_messages[math.random(#ground_messages)]
        TheNet:Say(message..r_message..pos_message.." ground")
    end,
    ["item"] = function(act)
        local message,pos_message,object_name,stack_size,item_name_many,article = EnvironmentPinger:HandleBaseMessageInformation(act)
        local item_messages = pingstrings.item
        local r_message = item_messages[math.random(#item_messages)]
        if stack_size > 1 then
            r_message = string.gsub(r_message,"%%S",item_name_many)
            r_message = string.gsub(r_message,"this/these","these "..stack_size)
            r_message = string.gsub(r_message,"that/those","those "..stack_size)
        else
            r_message = string.gsub(r_message,"%%S",object_name)
            r_message = string.gsub(r_message,"this/these","this")
            r_message = string.gsub(r_message,"that/those","that")
        end
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." item")
    end,
    
    ["structure"] = function(act)
        local message,pos_message,object_name,stack_size,item_name_many,article = EnvironmentPinger:HandleBaseMessageInformation(act)
        local structure_messages = pingstrings.structure
        local r_message = structure_messages[math.random(#structure_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." structure")
    end,
    
    ["mob"] = function(act)
        local message,pos_message,object_name,stack_size,item_name_many,article = EnvironmentPinger:HandleBaseMessageInformation(act)
        local mob_messages = pingstrings.mob
        local r_message = mob_messages[math.random(#mob_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." mob")
    end,
    
    ["boss"] = function(act)
        local message,pos_message,object_name,stack_size,item_name_many,article = EnvironmentPinger:HandleBaseMessageInformation(act)
        local boss_messages = pingstrings.boss
        local r_message = boss_messages[math.random(#boss_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." boss")
    end,
    
    ["other"] = function(act)
        local message,pos_message,object_name,stack_size,item_name_many,article = EnvironmentPinger:HandleBaseMessageInformation(act)
        local other_messages = pingstrings.other
        local r_message = other_messages[math.random(#other_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." other")
    end,
}

function EnvironmentPinger:IsValidPingType(ping_type)
    return ping_types[ping_type] ~= nil
end

function EnvironmentPinger:HandlePingType(ping_type,act)
    return ping_types[ping_type] ~= nil and ping_types[ping_type](act)
end

local random_environment_messages = {
    "Guys, are you blind? Look over here!",
    "Look over here!",
    "Look!",
    "Look here!",
}
    
function EnvironmentPinger:Ping(ping_type,act)
    self:HandlePingType(ping_type,act)
end

return EnvironmentPinger