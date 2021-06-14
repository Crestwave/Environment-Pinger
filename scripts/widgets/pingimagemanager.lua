local Widget = require "widgets/widget"
local Image = require "widgets/image"
local Text = require "widgets/text"

local PingImageManager = Class(Widget,function(self,inst)
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
        self:StartUpdating()
    end)

function PingImageManager:AddIndicator(source,ping_type,position,colour)
    if self.indicators[source] then
       self.indicators[source].widget:Kill()
       self.indicators[source] = nil
    end
    position = position and position.x and {position.x,position.y,position.z} or {0,0,0}
    local img = self.images[ping_type]
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
      data.widget:SetPosition(pos_x,pos_y)
      if self.owner and self.owner:IsValid() then
          local x,y,z = self.owner.Transform:GetWorldPosition()
          local dist = string.format("%.2f",math.sqrt(Dist2dSq({x = x, y = z},{x = data.pos[1], y = data.pos[3]})))
         data.widget.text_distance:SetString(dist.."m")
      end
   end
end

function PingImageManager:OnUpdate(dt)
   self:UpdateIndicatorPositions()
end

return PingImageManager