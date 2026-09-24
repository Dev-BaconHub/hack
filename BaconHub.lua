if not game:IsLoaded() then game.Loaded:Wait() end

local PlaceId = game.PlaceId
local UniverseID = game.GameId

local bloxFruitsPlaces = {
    [2753915549] = true,
    [85211729168715] = true,
    [4442272183] = true,
    [79091703265657] = true,
    [7449423635] = true,
    [100117331123089] = true,
}

if bloxFruitsPlaces[PlaceId] or UniverseID == 994732206 then
    -- Blox Fruits
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-BaconHub/hack/refs/heads/main/Bloxfruits.lua"))()
elseif PlaceId == 124216119978534 or UniverseID == 10035204815 then
    -- Ride A Pet
    loadstring(game:HttpGet("https://bacon-hub.xyz/loaders/Rideapet.lua"))()
elseif PlaceId == 9391468976 or UniverseID == 3508322461 then
    -- Jujutsu Kaisen
    loadstring(game:HttpGet("https://bacon-hub.xyz/loaders/Jujutsukaisen.lua"))()
end
