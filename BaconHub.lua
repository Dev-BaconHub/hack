local supportedPlaces = {
    [2753915549] = true,
    [85211729168715] = true,
    [4442272183] = true,
    [79091703265657] = true,
    [7449423635] = true,
    [100117331123089] = true,
}

if supportedPlaces[game.PlaceId] then
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Dev-BaconHub/hack/refs/heads/main/Bloxfruits.lua"))()
else
    loadstring(game:HttpGet("https://bacon-hub.xyz/loaders/Rideapet.lua"))()
end
