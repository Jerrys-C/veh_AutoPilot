local cruisedSpeed = 0
local vehicleClasses = {
    [0] = true,
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = true,
    [8] = true,
    [9] = true,
    [10] = true,
    [11] = true,
    [12] = true,
    [13] = false,
    [14] = false,
    [15] = false,
    [16] = false,
    [17] = true,
    [18] = true,
    [19] = true,
    [20] = true,
    [21] = false
}

local hands_on_steering_wheel_cooldown = false
local function hands_on_steering_wheel()
    if hands_on_steering_wheel_cooldown then return end
    SendNUIMessage({
        transactionType = 'hands_on_steering_wheel'
    })
    hands_on_steering_wheel_cooldown = true
    Citizen.SetTimeout(5000, function()
        hands_on_steering_wheel_cooldown = false
    end)
end

local autopilot_alert_cooldown = false
local function autopilot_alert()
    if autopilot_alert_cooldown then return end
    SendNUIMessage({
        transactionType = 'autopilot_alert'
    })
    autopilot_alert_cooldown = true
    Citizen.SetTimeout(5000, function()
        autopilot_alert_cooldown = false
    end)
end

local function TriggerCruiseControl()
    local NOACoords = nil
    local isCruiseControlEnabled = false
    if cache.seat == -1 then
        local blip = GetFirstBlipInfoId(8)
        if not IsVehicleOnAllWheels(cache.vehicle) then
            autopilot_alert()
            return
        end
        if DoesBlipExist(blip) then
            NOACoords = GetBlipInfoIdCoord(blip)  -- 获取标记点的坐标
            TaskVehicleDriveToCoordLongrange(cache.ped, cache.vehicle, NOACoords.x, NOACoords.y, NOACoords.z, 35.0, 1345083563, 50.0)
            SendNUIMessage({
                transactionType = 'noa_enabled'
            })
        else
            cruisedSpeed = GetEntitySpeed(cache.vehicle)
            if cruisedSpeed >= 10 and GetVehicleCurrentGear(cache.vehicle) > 0 then
                TaskVehicleDriveWander(cache.ped, cache.vehicle, cruisedSpeed, 1345083563)
                SendNUIMessage({
                    transactionType = 'autosteer_enabled'
                })
            else
                autopilot_alert()
                return
            end
        end
        local initBodyHealth = GetVehicleBodyHealth(cache.vehicle)
        isCruiseControlEnabled = true
        Wait(1000)

        CreateThread(function()
            while cache.vehicle do
                if not isCruiseControlEnabled then return end
                Wait(50)
                local speed = GetEntitySpeed(cache.vehicle)
                local currnetBodyHealth = GetVehicleBodyHealth(cache.vehicle)
                if initBodyHealth - currnetBodyHealth >= 5 then
                    ClearPedTasks(cache.ped)
                    SendNUIMessage({
                        transactionType = 'forward_collision_warning'
                    })
                    isCruiseControlEnabled = false
                    break
                end
                local turningOrBraking = IsControlPressed(2, 76) or IsControlPressed(2, 63) or IsControlPressed(2, 64) or IsControlPressed(2, 72)

                if not IsVehicleOnAllWheels(cache.vehicle) then
                    hands_on_steering_wheel()
                end

                -- if IsControlPressed(2, 71) then
                --     SetVehicleForwardSpeed(cache.vehicle, speed + 0.6)
                -- end

                if turningOrBraking then
                    ClearPedTasks(cache.ped)
                    SendNUIMessage({
                        transactionType = 'autosteer_disabled'
                    })
                    isCruiseControlEnabled = false
                    break
                end
            end
        end)

        CreateThread(function()
            while cache.vehicle do
                if not isCruiseControlEnabled then return end
                Wait(500)
                if NOACoords then
                    local distance = #(GetEntityCoords(cache.vehicle) - NOACoords)
                    if distance <= 50 then
                        ClearPedTasks(cache.ped)
                        SendNUIMessage({
                            transactionType = 'noa_disabled'
                        })
                        isCruiseControlEnabled = false
                        return
                    end
                end
            end
        end)
    end
end

local keybindCruiseControl = lib.addKeybind({name = 'toggle_cruise_control', description = 'auto pilot', defaultKey = 'Y',
    onPressed = function(self)
        if cache.seat == -1 then
            local vehicleClass = GetVehicleClass(cache.vehicle)
            if vehicleClasses[vehicleClass] then
                TriggerCruiseControl()
            else
                lib.notify({type = 'error', text = 'This vehicle class does not support auto pilot'})
            end
        end
    end
})

return {
    keybindCruiseControl = keybindCruiseControl -- possibility of apler to deactivate/activate
}
