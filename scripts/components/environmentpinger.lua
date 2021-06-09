local EnvironmentPinger = Class(function(self,inst)
        self.owner = inst
        self.indicators = {}
        
    end)

function EnvironmentPinger:OverrideOnMessageReceivedfn()
    
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


function EnvironmentPinger:HandlePingType(ping_type,act)
    local ping_types = {
    }
end

local random_environment_messages = {
    "Guys, are you blind? Look over here!",
    "Look over here!",
    "Look!",
    "Look here!",
}
    
function EnvironmentPinger:Ping(ping_type,act)
    local ping_types = {"ground","item","structure","mob","boss","other"}
    local target = act.target
    local pos = target and target:GetPosition() or TheInput:GetWorldPosition()
    local pos_message = "\n{"..string.format("%.3f",pos.x)..","..string.format("%.3f",pos.z).."}"
    
    
    local message = STRINGS.LMB.." "
    local display_adjective_fn,object_name
    local stackable,stack_size,cant_be_pluralized,item_name_many,article
    if target then
        display_adjective_fn = target and target.displayadjectivefn
        object_name = display_adjective_fn ~= nil and display_adjective_fn().." "..target:GetDisplayName() or target:GetDisplayName()
        
        if self:IsOnFire(target) then
            object_name = "Burning "..object_name
        elseif self:IsBurnt(target) then
            object_name = "Burnt "..object_name
        end
        
        stackable = target.replica.stackable
        stack_size = stackable and stackable:StackSize() or 1
        cant_be_pluralized = string.match(object_name,"%a+(s)$") -- Last words letter is 's'
        item_name_many = cant_be_pluralized and object_name or object_name.."s"
        article = string.match(object_name,"^[AEIOUaeiou]") and "an " or "a "
        
        if stack_size > 1 then
            message = "There are "..stack_size.." "..item_name_many.." here!"
        else
            message = message.."There is "..article..object_name.." here!"
        end
    else
        message = message..random_environment_messages[math.random(#random_environment_messages)]
    end
    TheNet:Say(message..pos_message)
end

return EnvironmentPinger