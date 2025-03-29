local pingstrings = require "environmentpinger/pingstrings"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
local PingImageManager = require "widgets/pingimagemanager"
local Encryptor = require "environmentpinger/encryptor"
local cooldown_thread = nil
local function LoadConfig(name)
	local mod = "Environment Pinger [Fixed]"
	return GetModConfigData(name,mod) or GetModConfigData(name,KnownModIndex:GetModActualName(mod))
end
local whisper_key = LoadConfig("whisper_key")
local encryptdata = LoadConfig("encryptdata")

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
local cipher = nil
local EnvironmentPinger = Class(function(self,inst)
        self.owner = inst
        current_world = TheWorld and TheNet:GetSessionIdentifier()
        cipher = tostring(Encryptor.HashString(current_world,8))
        self.cooldown = false
    end)


function EnvironmentPinger:SetClickableMessage(chatline)
    local base_pattern = STRINGS.LMB..".+"..STRINGS.RMB.." "
    local data_pattern = base_pattern.."{[-]?%d*%.?%d+,[-]?%d*%.?%d+} %S+ %S+"
    local message = chatline.message:GetString()
    local name = chatline.user:GetString()
    local colour = chatline.user:GetColour()
    local is_message_ping = string.match(message,base_pattern..".+") or string.match(message,data_pattern)
    local on_click_fn = function()
        self:OnMessageReceived(nil, nil, nil, nil, name, nil, message, colour, nil, nil, nil,true,true)
    end
    if chatline.message_btn then
        chatline.message_btn:SetText(message)
        chatline.message_btn:SetOnClick(on_click_fn)
        if not is_message_ping then
            chatline.message_btn:Hide()
        else
            chatline.message_btn:Show()
            local w1, h1 = chatline.message_btn.text:GetRegionSize()
            chatline.message_btn:SetPosition(w1 * 0.5 - 290, 0)
            chatline.message:Hide()
        end
    end
    if not is_message_ping then
        return
    end
    if not chatline.message_btn then
        chatline.message_btn = chatline.root:AddChild(ImageButton())
        chatline.message_btn.text:SetHAlign(ANCHOR_LEFT)
        chatline.message_btn:SetFont(TALKINGFONT)
        chatline.message_btn:SetTextSize(30)
        chatline.message_btn:SetImageNormalColour(0, 0, 0, 0)
        chatline.message_btn:SetTextColour(1, 1, 1, 1)
        chatline.message_btn:SetTextFocusColour(1, 1, 1, 1)
        chatline.message_btn:SetOnClick(on_click_fn)
        chatline.message_btn:SetControl(CONTROL_PRIMARY) --mouse left click only!
        chatline.message_btn:SetText(message)
        local w1, h1 = chatline.message_btn.text:GetRegionSize()
        chatline.message_btn:SetPosition(w1 * 0.5 - 290, 0)
        chatline.message_btn:ForceImageSize(w1,h1)
        chatline.message_btn:Show()
    end
    chatline.message:Hide()
    -- Why does it have to be so painful to just edit the chat widget?
end

function EnvironmentPinger:OnMessageReceived(chathistory,guid,userid, netid, name, prefab, message, colour, whisper, isemote, user_vanity, ignore_sound, ignore_mobs)
    local base_pattern = STRINGS.LMB..".+"..STRINGS.RMB.." "
    local data_pattern = base_pattern.."{[-]?%d*%.?%d+,[-]?%d*%.?%d+} %S+ %S+"
    if (not string.match(message,data_pattern)) and string.match(message,base_pattern..".+") then
        message = string.match(message,base_pattern)..Encryptor.E(string.match(message,base_pattern.."(%S+)") or "",cipher)
    end
    if string.match(message,data_pattern) then
       local pos_str = string.match(message,base_pattern.."{([-]?%d*%.?%d+,[-]?%d*%.?%d+)} %S+")
       local pos_x = tonumber(string.match(pos_str,"(.+),"))
       local pos_z = tonumber(string.match(pos_str,",(.+)"))
       local ping_type = string.match(message,base_pattern.."{[-]?%d*%.?%d+,[-]?%d*%.?%d+} (%S+)")
       local world = string.match(message,base_pattern.."{[-]?%d*%.?%d+,[-]?%d*%.?%d+} %S+ (%S+)")
       -- As the world identifier, let us use the session id.
       if world and not (current_world == world) then return nil end -- Different world means different ping meaning.
       if EnvironmentPinger:IsValidPingType(ping_type) then
           self:AddIndicator(name,ping_type,{x = pos_x,y = 0,z = pos_z},colour,ignore_sound,ignore_mobs)
       end
    end
end

function EnvironmentPinger:AddIndicator(source,ping_type,pos,colour,ignore_sound,ignore_mobs)
    if not self.pingimagemanager and self.owner:IsValid() and self.owner.HUD then
        self.pingimagemanager = self.owner.HUD:AddChild(PingImageManager(self.owner))
    end
    if self.pingimagemanager then
        self.pingimagemanager:AddIndicator(source,ping_type,pos,colour,ignore_sound,ignore_mobs)
    end
end

function EnvironmentPinger:MoveWaypointToPos(pos)
    if not self.pingimagemanager and self.owner:IsValid() and self.owner.HUD then
        self.pingimagemanager = self.owner.HUD:AddChild(PingImageManager(self.owner))
    end
    self.pingimagemanager:MoveWaypointToPos(pos)
end

function EnvironmentPinger:SetIndicatorsToMapPositions(bool,map)
    if not self.pingimagemanager and self.owner:IsValid() and self.owner.HUD then
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

function EnvironmentPinger:HandleBaseMessageInformation(act,message_type)
    local target = act.target
    local pos = target and target:GetPosition() or act.position or TheInput:GetWorldPosition()
    local pos_message = pos and "{"..string.format("%.3f",pos.x)..","..string.format("%.3f",pos.z).."}" or ""
    local message_type_data = message_type or ""
    local current_world_data = current_world or tostring(TheNet:GetSessionIdentifier())
    local message = STRINGS.LMB.." "
    local data_message = string.format("%s %s %s",pos_message,message_type_data,current_world_data)
    if encryptdata then
        data_message = STRINGS.RMB.." "..Encryptor.E(data_message,cipher)
    else
        data_message = STRINGS.RMB.." "..data_message
    end
    if target then
        local display_adjective = target and target.displayadjectivefn and target.displayadjectivefn(target)
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
        local object_data = {
            prefab = prefab,
            object_name = object_name,
            stack_size = stack_size,
            item_name_many = item_name_many,
            article = article,
        }
        return message,data_message,object_data
    end
    return message,data_message
end

local ping_types = {
    ["ground"] = function(act,whisper,ping_type)
        local message,data_message = EnvironmentPinger:HandleBaseMessageInformation(act,"ground",ping_type)
        local ground_messages = pingstrings.ground
        local r_message = ground_messages[math.random(#ground_messages)]
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    ["item"] = function(act,whisper,ping_type)
        local message,data_message,object_data = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        --Unpack data into local variables
        local prefab = object_data.prefab
        local object_name = object_data.object_name
        local stack_size = object_data.stack_size
        local item_name_many = object_data.item_name_many
        local article = object_data.article
        
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
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    
    ["structure"] = function(act,whisper,ping_type)
        local message,data_message,object_data = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        --Unpack object data into local variables
        local prefab = object_data.prefab
        local object_name = object_data.object_name
        local article = object_data.article
        
        local structure_messages = SumTables(pingstrings.structure,pingstrings.custom[prefab])
        local r_message = structure_messages[math.random(#structure_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    
    ["mob"] = function(act,whisper,ping_type)
        local message,data_message,object_data = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        --Unpack object data into local variables
        local prefab = object_data.prefab
        local object_name = object_data.object_name
        local article = object_data.article
        
        local mob_messages = SumTables(pingstrings.mob,pingstrings.custom[prefab])
        local r_message = mob_messages[math.random(#mob_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    
    ["boss"] = function(act,whisper,ping_type)
        local message,data_message,object_data = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        --Unpack object data into local variables
        local prefab = object_data.prefab
        local object_name = object_data.object_name
        local article = object_data.article
        
        local boss_messages = SumTables(pingstrings.boss,pingstrings.custom[prefab])
        local r_message = boss_messages[math.random(#boss_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    
    ["map"] = function(act,whisper,ping_type)
        local message,data_message = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        local map_messages = pingstrings.map
        local r_message = map_messages[math.random(#map_messages)]
        TheNet:Say(message..r_message..data_message,whisper)
    end,
    ["other"] = function(act,whisper,ping_type)
        local message,data_message,object_data = EnvironmentPinger:HandleBaseMessageInformation(act,ping_type)
        --Unpack object data into local variables
        local prefab = object_data.prefab
        local object_name = object_data.object_name
        local article = object_data.article
        
        local other_messages = SumTables(pingstrings.other,pingstrings.custom[prefab])
        local r_message = other_messages[math.random(#other_messages)]
        r_message = string.gsub(r_message,"%%S",object_name)
        r_message = string.gsub(r_message,"a/an",article)
        TheNet:Say(message..r_message..data_message,whisper)
    end,
}

function EnvironmentPinger:IsValidPingType(ping_type)
    return ping_types[ping_type] ~= nil
end

function EnvironmentPinger:HandlePingType(ping_type,act,whisper)
    return ping_types[ping_type] ~= nil and ping_types[ping_type](act,whisper,ping_type)
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
