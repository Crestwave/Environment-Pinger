local _G = GLOBAL

local require = _G.require

local TheInput = _G.TheInput
local ACTIONS = _G.ACTIONS
local BufferedAction = _G.BufferedAction

local action_prefix = "MOD_ENVIRONMENT_PINGER_"
local ping_ground_name = action_prefix.."PING"
local ping_item_name = action_prefix.."PING_ITEM"
local ping_structure_name = action_prefix.."PING_STRUCTURE"
local ping_mob_name = action_prefix.."PING_MOB"
local ping_boss_name = action_prefix.."PING_BOSS"
local ping_other_name = action_prefix.."PING_OTHER"

local function GetConfig(name)
    return GetModConfigData(name)
end

local ping_key = GetConfig("ping_key")

local function ping_ground_fn(act)
    --print("Ping ground")
    if act and act.doer then
       act.doer.components.environmentpinger:Ping("ground",act) 
    end
end

local function ping_item_fn(act)
    --print("Ping item")
    if act and act.doer then
       act.doer.components.environmentpinger:Ping("item",act) 
    end
end

local function ping_structure_fn(act)
    --print("Ping structure")
    if act and act.doer then
       act.doer.components.environmentpinger:Ping("structure",act) 
    end
end

local function ping_mob_fn(act)
   --print("Ping mob")
   if act and act.doer then
       act.doer.components.environmentpinger:Ping("mob",act) 
    end
end

local function ping_boss_fn(act)
    --print("Ping boss")
    if act and act.doer then
       act.doer.components.environmentpinger:Ping("boss",act) 
    end
end

local function ping_other_fn(act)
    --print("Ping other")
    if act and act.doer then
       act.doer.components.environmentpinger:Ping("other",act) 
    end
end

local function MoveWaypointToMousePos()
    if _G.ThePlayer and _G.ThePlayer.components.environmentpinger then
        local pos = TheInput:GetWorldPosition()
       _G.ThePlayer.components.environmentpinger:MoveWaypointToPos(pos)
    end
end



AddAction(ping_ground_name,"Ping ground",ping_ground_fn)
AddAction(ping_item_name,"Ping item",ping_item_fn)
AddAction(ping_structure_name,"Ping structure",ping_structure_fn)
AddAction(ping_mob_name,"Ping mob",ping_mob_fn)
AddAction(ping_boss_name,"Ping boss",ping_boss_fn)
AddAction(ping_other_name,"Ping",ping_other_fn)
-- Check for a fire as a valid sub-type in all ping types.
-- Or rather, add it as an adjective for the objects.
-- Could ping sub-types be useful? Eg. Mob dividing into friendly, neutral, agressive, boss?

local function PlayerActionPickerPostInit(playeractionpicker,player)
    if player ~= _G.ThePlayer then
        return 
    end
    
    local old_DoGetMouseActions = playeractionpicker.DoGetMouseActions
    playeractionpicker.DoGetMouseActions = function(self,position,target)
       local lmb, rmb = old_DoGetMouseActions(self,position,target)
       if TheInput:IsKeyDown(ping_key) then
           local entity_target = TheInput:GetWorldEntityUnderMouse()
           local hud_entity = TheInput:GetHUDEntityUnderMouse()
           
           if hud_entity then
               return lmb,rmb
           end
           if not entity_target then --Ping the ground or so
               lmb = BufferedAction(player,nil,ACTIONS[ping_ground_name])
               return lmb,rmb
           end
           
           if entity_target:HasTag("epic") then
              lmb = BufferedAction(player,entity_target,ACTIONS[ping_boss_name])
          elseif entity_target:HasTag("_inventoryitem") and entity_target.replica.inventoryitem:CanBePickedUp() then
              lmb = BufferedAction(player,entity_target,ACTIONS[ping_item_name])
          elseif entity_target:HasTag("structure") or entity_target:HasTag("hammer_WORKABLE") then
              lmb = BufferedAction(player,entity_target,ACTIONS[ping_structure_name])
          elseif entity_target:HasTag("_health") then
              lmb = BufferedAction(player,entity_target,ACTIONS[ping_mob_name])
          else
              lmb = BufferedAction(player,entity_target,ACTIONS[ping_other_name])
           end
       end
       return lmb,rmb
    end
end

local function PlayerControllerPostInit(playercontroller,player)
    if player ~= _G.ThePlayer then
        return
    end
    _G.ThePlayer:AddComponent("environmentpinger")
    local old_OnLeftClick = playercontroller.OnLeftClick
    
    playercontroller.OnLeftClick = function(self, down, ...)
        local lmb = self:GetLeftMouseAction()
       if (not down) and lmb and lmb.action.id and string.match(lmb.action.id,action_prefix) then
           lmb.action.fn(lmb)
           return
       end
       old_OnLeftClick(self,down, ...)
    end
    
    local old_OnRightClick = playercontroller.OnRightClick
    
    playercontroller.OnRightClick = function(self, down, ...)
        local rmb = self:GetRightMouseAction()
       if (not down) and rmb and rmb.action.id and string.match(rmb.action.id,action_prefix) then
           rmb.action.fn(rmb)
           return
       end
       if (not down) and ping_key ~= 0 and TheInput:IsKeyDown(ping_key) then
            if not (tostring(_G.TheFrontEnd:GetActiveScreen()) == "MapScreen") and not TheInput:GetHUDEntityUnderMouse() then -- Handled elsewhere.
                MoveWaypointToMousePos() 
            end
       end
       old_OnRightClick(self,down, ...)
    end
    
end

local function PlayerPostInit(player)
    player:DoTaskInTime(0,function()
        if player ~= _G.ThePlayer then
            return
        end
        if not player.components.environmentpinger then
            player:AddComponent("environmentpinger")
        end
        if player.HUD then
            local networkchatqueue = player.HUD.controls.networkchatqueue
            local old_OnMessageReceived = networkchatqueue.OnMessageReceived
            networkchatqueue.OnMessageReceived = function(...)
                player.components.environmentpinger:OnMessageReceived(...)
                old_OnMessageReceived(...)
            end
        end
    end)
end

local function MapScreenPostInit(self)
    if not _G.ThePlayer then return nil end
    
    
    local old_OnBecomeActive = self.OnBecomeActive
    
    self.OnBecomeActive = function(self)
        if _G.ThePlayer.components.environmentpinger then
           _G.ThePlayer.components.environmentpinger:SetIndicatorsToMapPositions(true,self)
        end
       old_OnBecomeActive(self)
    end
    
    
    local old_OnBecomeInactive = self.OnBecomeInactive
    
    self.OnBecomeInactive = function(self)
       if _G.ThePlayer.components.environmentpinger then
           _G.ThePlayer.components.environmentpinger:SetIndicatorsToMapPositions(false,self) 
        end
       old_OnBecomeInactive(self)
    end
    
    
    local old_OnControl = self.OnControl
    
    self.OnControl = function(self,control,down)
        if (not down) and (control == 29 or control == 1) and TheInput:IsKeyDown(ping_key) then
             -- CONTROL_ACCEPT = 29 = Leftclick on the map. It's also the [Enter] key.
             -- CONTROL_SECONDARY = 1 = Rightclick on the map
            if _G.ThePlayer.components.environmentpinger then
                local pos = TheInput:GetScreenPosition()
                local widget_pos = self:ScreenPosToWidgetPos(pos)
                local world_pos = self:WidgetPosToMapPos(widget_pos)
                local x,y,z = self.minimap:MapPosToWorldPos(world_pos.x,world_pos.y,world_pos.z)
                if control == 29 then
                    _G.ThePlayer.components.environmentpinger:Ping("map",{position = {x = x, z = y}})
                else
                    _G.ThePlayer.components.environmentpinger:MoveWaypointToPos({x = x, y = 0, z = y})
                end
            end
        end
        
        old_OnControl(self,control,down)
    end
end
AddComponentPostInit("playeractionpicker",PlayerActionPickerPostInit)
AddComponentPostInit("playercontroller", PlayerControllerPostInit)
AddClassPostConstruct("screens/mapscreen", MapScreenPostInit)
AddPlayerPostInit(PlayerPostInit)

