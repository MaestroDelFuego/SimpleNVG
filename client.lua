local nightVisionOn = false

Config = {}
Config.AllowedVehicles = {
    { label = "Lazer Jet", model = "lazer" },
    { label = "Hydra Jet", model = "hydra" },
    { label = "Raiju Jet", model = "raiju" },
    { label = "Alkonost Bomber", model = "alkonost" },
    { label = "B11 Strikeforce", model = "strikeforce" }
}

-- Auto-disable NVG if player exits allowed aircraft
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000) -- Check every second

        if nightVisionOn and not IsInAllowedAircraft() then
            nightVisionOn = false
            SetNightvision(false)
        end
    end
end)

-- Check if player is in allowed aircraft
function IsInAllowedAircraft()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then
        local veh = GetVehiclePedIsIn(ped, false)
        local model = GetEntityModel(veh)

        for _, vehicle in pairs(Config.AllowedVehicles) do
            if GetHashKey(vehicle.model) == model then
                return true
            end
        end
    end
    return false
end

-- Manual key check: Alt + B to toggle NVG
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        -- ALT = 19, B = 29
        if IsControlPressed(0, 19) and IsControlJustPressed(0, 29) then
            if IsInAllowedAircraft() then
                nightVisionOn = not nightVisionOn
                SetNightvision(nightVisionOn)
            else
                TriggerEvent("chat:addMessage", {
                    args = { "^1Night vision can only be used in allowed aircraft." }
                })
            end
        end
    end
end)

-- HUD display
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if IsInAllowedAircraft() then
            local textureDict = "NVGHUD"
            local spriteName = nightVisionOn and "NVG_ON" or "NVG_OFF"

            -- Load texture if needed
            if not HasStreamedTextureDictLoaded(textureDict) then
                RequestStreamedTextureDict(textureDict, true)
                while not HasStreamedTextureDictLoaded(textureDict) do
                    Citizen.Wait(10)
                end
            end

            -- Draw the NVG HUD sprite
            DrawSprite(
                textureDict,
                spriteName,
                0.5,    -- X position (center)
                0.92,   -- Y position (bottom area)
                0.10,   -- Width (adjust for visibility)
                0.15,   -- Height (adjust for visibility)
                0.0,    -- Rotation
                255, 255, 255, 255 -- Color (white, full opacity)
            )
        end
    end
end)
