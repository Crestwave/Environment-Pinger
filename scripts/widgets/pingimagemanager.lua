local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local TOP_EDGE_BUFFER = 30
local BOTTOM_EDGE_BUFFER = 40
local LEFT_EDGE_BUFFER = 67
local RIGHT_EDGE_BUFFER = 80
local screen_x,screen_z


local PingImageManager = Class(Widget,function(self,inst)
        screen_x,screen_z = TheSim:GetScreenSize()
        self.owner = inst
        Widget._ctor(self,"PingImageManager")
        self.indicators = {}
        self.tasks = {}
        --Format: {[source] = {widget = widget, pos = pos, target = target}}
        self.images = {
         ["ground"] = {atlas = "images/inventoryimages.xml", tex = "turf_grass.tex"},
         ["item"] = {atlas = "images/inventoryimages1.xml", tex = "minifan.tex"},
         ["structure"] = {atlas = "images/hud.xml", tex = "tab_build.tex"},
         ["mob"] = {atlas = "images/inventoryimages.xml", tex = "mole.tex"},
         ["boss"] = {atlas = "images/inventoryimages.xml", tex = "deerclops_eyeball.tex"},
         ["other"] = {atlas = "images/inventoryimages.xml", tex = "nightmare_timepiece.tex"},
         ["background"] = {atlas = "images/avatars.xml",tex = "avatar_frame_white.tex"},
        }
        self:Show()
        self:SetClickable(false)
        self:MoveToBack()
        self:StartUpdating()
    end)

function PingImageManager:AddIndicator(source,ping_type,position,colour)
    if self.indicators[source] then
       self.indicators[source].widget:Kill()
       self.indicators[source] = nil
    end
    position = position and position.x and {position.x,position.y,position.z} or {0,0,0}
    local img = self.images[ping_type]
    if not img then return nil end
    local img_widget = self:AddChild(Image(img.atlas,img.tex))
    img_widget:SetScale(0.5,0.5,0.5)
    self:AddIndicatorBackgroundAndText(source,img_widget,ping_type,colour)
    local target
    local entities = TheSim:FindEntities(position[1],position[2],position[3],1,{},{"INLIMBO"},{"epic","_inventoryitem","structure","_health"})
    target = ping_type ~= "ground" and entities[1]
    self.indicators[source] = {widget = img_widget, pos = position, target = target}
    
    local remove_task = self.tasks[source]
    if remove_task then
        remove_task:Cancel()
        self.tasks[source] = nil
    end
    self.tasks[source] = self.owner:DoTaskInTime(20,function() self.indicators[source].widget:Kill() self.indicators[source] = nil end)
    self:UpdateIndicatorPositions()
end


function PingImageManager:AddIndicatorBackgroundAndText(source,img_widget,ping_type,colour)
    local background = self.images.background
    img_widget.bg = img_widget:AddChild(Image(background.atlas,background.tex))
    img_widget.bg:SetTint(unpack(colour))
    img_widget.text = img_widget:AddChild(Text(NUMBERFONT,32))
    img_widget.text:SetPosition(0,64)
    img_widget.text:SetString(source)
    img_widget.text:SetColour(unpack(colour))
    img_widget.text_distance = img_widget:AddChild(Text(NUMBERFONT,32))
    img_widget.text_distance:SetPosition(0,-64)
    img_widget.text_distance:SetColour(unpack(colour))
end

function PingImageManager:UpdateIndicatorPositions()
   for source,data in pairs(self.indicators) do
      local target = data.target
      if target and target:IsValid() and not target:HasTag("INLIMBO") then
          local pos = {target.Transform:GetWorldPosition()}
          self.indicators[source].pos = pos
      elseif target then
          self.indicators[source].target = nil
      end
      local pos_x,pos_y = TheSim:GetScreenPos(unpack(data.pos))
      if pos_x > screen_x or pos_x < 0 or pos_y < 0 or pos_y > screen_z then
         self:DoOffscreenIndicator(data.widget,data.pos,screen_x,screen_z)
      else
         data.widget:SetPosition(pos_x,pos_y)
      end
      if self.owner and self.owner:IsValid() then
          local x,y,z = self.owner.Transform:GetWorldPosition()
          local dist = string.format("%.2f",math.sqrt(Dist2dSq({x = x, y = z},{x = data.pos[1], y = data.pos[3]})))
         data.widget.text_distance:SetString(dist.."m")
      end
   end
end

local function GetXCoord(angle, width)
    if angle >= 90 and angle <= 180 then -- left side
        return 0
    elseif angle <= 0 and angle >= -90 then -- right side
        return width
    else -- middle somewhere
        if angle < 0 then
            angle = -angle - 90
        end
        local pctX = 1 - (angle / 90)
        return pctX * width
    end
end

local function GetYCoord(angle, height)
    if angle <= -90 and angle >= -180 then -- top side
        return height
    elseif angle >= 0 and angle <= 90 then -- bottom side
        return 0
    else -- middle somewhere
        if angle < 0 then
            angle = -angle
        end
        if angle > 90 then
            angle = angle - 90
        end
        local pctY = (angle / 90)
        return pctY * height
    end
end

function PingImageManager:DoOffscreenIndicator(widget,pos,screenWidth,screenHeight)
    -- On the one hand, I could scale it,
    -- on the other hand, the player can see the distance so I'm too lazy to scale it.
    local angleToTarget = self.owner:GetAngleToPoint(unpack(pos))
    local downVector = TheCamera:GetDownVec()
    local downAngle = -math.atan2(downVector.z, downVector.x) / DEGREES
    local indicatorAngle = (angleToTarget - downAngle) + 45 -- Based of the South East being the starting angle system. Clockwise.
    while indicatorAngle > 180 do indicatorAngle = indicatorAngle - 360 end
    while indicatorAngle < -180 do indicatorAngle = indicatorAngle + 360 end
    local x = GetXCoord(indicatorAngle,screenWidth)
    local y = GetYCoord(indicatorAngle,screenHeight)
    
    if x <= LEFT_EDGE_BUFFER then 
        x = LEFT_EDGE_BUFFER
    elseif x >= screenWidth - RIGHT_EDGE_BUFFER then
        x = screenWidth - RIGHT_EDGE_BUFFER
    end

    if y <= 2*BOTTOM_EDGE_BUFFER then 
        y = 2*BOTTOM_EDGE_BUFFER
    elseif y >= screenHeight - 2*TOP_EDGE_BUFFER then
        y = screenHeight - 2*TOP_EDGE_BUFFER
    end
    
    widget:SetPosition(x,y,0)
end

function PingImageManager:OnUpdate(dt)
   self:UpdateIndicatorPositions()
end

return PingImageManager