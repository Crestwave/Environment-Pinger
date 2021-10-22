local pingstrings = require "environmentpinger/pingstrings"
local Image = require "widgets/image"
local PingImageManager = require "widgets/pingimagemanager"
local cooldown_thread = nil
local function LoadConfig(name)
	local mod = "Environment Pinger"
	return GetModConfigData(name,mod) or GetModConfigData(name,KnownModIndex:GetModActualName(mod))
end
local whisper_key = LoadConfig("whisper_key")

local function SumTables(table_1,table_2)
    local new_table = {}
    if type(table_1) == "table" and type(table_2) == "table" then
        for k,v in pairs(table_1) do
            table.insert(new_table,v)
        end
        for k,v in pairs(table_2) do
            table.insert(new_table,v)
        end
        return new_table
    elseif type(table_1) == "table" then
        return table_1
    elseif type(table_2) == "table" then
        return table_2
    else
        return nil
    end
end

local current_world

local EnvironmentPinger = Class(function(self,inst)
        self.owner = inst
        current_world = TheWorld and TheWorld:HasTag("cave") and "2" or "1"
        -- 2 - Caves, 1 - Surface
        self.cooldown = false
    end)


function EnvironmentPinger:OnMessageReceived(chathistory,guid,userid, netid, name, prefab, message, colour, whisper, isemote, user_vanity)
    if string.match(message,STRINGS.LMB.." .+"..STRINGS.RMB.."{[-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+} %S+") then
       local pos_str = string.match(message,STRINGS.LMB.." .+"..STRINGS.RMB.."{([-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+)} %S+")
       local pos_x = tonumber(string.match(pos_str,"(.+),"))
       local pos_z = tonumber(string.match(pos_str,",(.+)"))
       local ping_type = string.match(message,STRINGS.LMB.." .+"..STRINGS.RMB.."{[-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+} (%S+)")
       local world = string.match(message,STRINGS.LMB.." .+"..STRINGS.RMB.."{[-]?%d+[%.%d+]+,[-]?%d+[%.%d+]+} %S+ (%d)")
       -- Assuming coordinates are 3 digit numbers, I am using 26~ characters worth of data.
       -- I could grab the session id, but that is 15 characters of data, which is way too much
       if world and not (current_world == world) then return nil end -- Different world means different ping meaning.
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

function EnvironmentPinger:MoveWaypointToPos(pos)
    if not self.pingimagemanager and self.owner.HUD then
        self.pingimagemanager = self.owner.HUD:AddChild(PingImageManager(self.owner))
    end
    self.pingimagemanager:MoveWaypointToPos(pos)
end

function EnvironmentPinger:SetIndicatorsToMapPositions(bool,map)
    if not self.pingimagemanager and self.owner.HUD then
        self.pingimagemanager = self.owner.HUD:AddChild(PingImageManager(self.owner))
    end
   self.pingimagemanager:SetIndicatorsToMapPositions(bool,map) 
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
    local pos = target and target:GetPosition() or act.position or TheInput:GetWorldPosition()
    local pos_message = pos and STRINGS.RMB.."{"..string.format("%.3f",pos.x)..","..string.format("%.3f",pos.z).."}" or ""
    local message = STRINGS.LMB.." "
    local current_world = current_world or "1"
    if target then
        local display_adjective = target and target.displayadjectivefn and target.displayadjectivefn()
        local base_name = target:GetDisplayName()
        if base_name == "MISSING NAME" then
            base_name = target.prefab
        end
        local object_name = display_adjective and display_adjective.." "..base_name or base_name
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
        local prefab = target.prefab
        return message,pos_message,prefab,object_name,stack_size,item_name_many,article,current_world
    end
    return message,pos_message,current_world
end

local ping_types = {
    ["ground"] = function(act,whisper)
        local message,pos_message,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local ground_messages = pingstrings.ground
        local r_message = ground_messages[math.random(#ground_messages)]
        TheNet:Say(message..r_message..pos_message.." ground".." "..current_world,whisper)
    end,
    ["item"] = function(act,whisper)
        local message,pos_message,prefab,
              object_name,stack_size,item_name_many,
              article,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local item_messages = SumTables(pingstrings.item,pingstrings.custom[prefab])
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
        -- Kinda feels ugly with the amount of times I change the variable.
        -- Might there be a better method for gsubing all of that?
        TheNet:Say(message..r_message..pos_message.." item".." "..current_world,whisper)
    end,
    
    ["structure"] = function(act,whisper)
        local message,pos_message,prefab,
              object_name,stack_size,item_name_many,
              article,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local structure_messages = SumTables(pingstrings.structure,pingstrings.custom[prefab])
        local r_message = structure_messages[math.random(#structure_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." structure".." "..current_world,whisper)
    end,
    
    ["mob"] = function(act,whisper)
        local message,pos_message,prefab,
              object_name,stack_size,item_name_many,
              article,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local mob_messages = SumTables(pingstrings.mob,pingstrings.custom[prefab])
        local r_message = mob_messages[math.random(#mob_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." mob".." "..current_world,whisper)
    end,
    
    ["boss"] = function(act,whisper)
        local message,pos_message,prefab,
              object_name,stack_size,item_name_many,
              article,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local boss_messages = SumTables(pingstrings.boss,pingstrings.custom[prefab])
        local r_message = boss_messages[math.random(#boss_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." boss".." "..current_world,whisper)
    end,
    
    ["map"] = function(act,whisper)
        local message,pos_message,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local map_messages = pingstrings.map
        local r_message = map_messages[math.random(#map_messages)]
        TheNet:Say(message..r_message..pos_message.." map".." "..current_world,whisper)
    end,
    ["other"] = function(act,whisper)
        local message,pos_message,prefab,
              object_name,stack_size,item_name_many,
              article,current_world = EnvironmentPinger:HandleBaseMessageInformation(act)
        local other_messages = SumTables(pingstrings.other,pingstrings.custom[prefab])
        local r_message = other_messages[math.random(#other_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..pos_message.." other".." "..current_world,whisper)
    end,
}

function EnvironmentPinger:IsValidPingType(ping_type)
    return ping_types[ping_type] ~= nil
end

function EnvironmentPinger:HandlePingType(ping_type,act,whisper)
    return ping_types[ping_type] ~= nil and ping_types[ping_type](act,whisper)
end
    
function EnvironmentPinger:Ping(ping_type,act)
    if self.cooldown then return nil end
    if not self.cooldown then
        self.cooldown = true
        cooldown_thread = StartThread(function()
                Sleep(1)
                self.cooldown = false
                KillThreadsWithID(cooldown_thread.id)
                cooldown_thread:SetList(nil)
                cooldown_thread = nil
            end)
        cooldown_thread.id = "MOD_ENVIRONMENT_PINGER_THREAD"
    end
    self:HandlePingType(ping_type,act,TheInput:IsKeyDown(whisper_key))
end

return EnvironmentPinger