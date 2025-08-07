local canRespawn = false
LocalPlayer.state:set("dead", false, true)

RegisterNUICallback('canRespawn', function(data, cb)
    canRespawn = data.allowRespawn
end)

local function notify(title, description, type, icon, duration)
    lib.notify({
        title = title,
        description = description,
        type = type,
        icon = icon,
        duration = duration or 3000
    })
end
local function disableNUI()
    if DeathScreen.BlurScreen then
        TriggerScreenblurFadeOut(2000)
    end
    SendNUIMessage({ type = 'hide' })
    SetNuiFocus(false, false)
end

RegisterNetEvent('SpawnHandler:NoPerm', function(type)
    notify('Permission Error', 'You do not have permission to do this.', 'error')
end)

RegisterNetEvent('SpawnHandler:InvalidID', function(type)
    notify('Spawn Handler Error', 'Invalid Server ID', 'error')
end)

-- used for respawning the character depending on if they 
local function respawnCharacter(adminInf)
    if DeathScreen.DefaultSpawns then
        canRespawn = false
        LocalPlayer.state:set("dead", false, true)
        exports.spawnmanager:setAutoSpawn(true)
        Wait(500)
        exports.spawnmanager:forceRespawn()
        SetPlayerInvincible(cache.playerId, false)
        disableNUI()
        Wait(500)

        exports.spawnmanager:setAutoSpawn(false)

        if adminInf then
            notify('Spawn Manager', ('You have been respawned by %s'):format(adminInf), 'success')
        else
            notify('Spawn Manager', 'You have been respawned', 'success')
        end
    else
        canRespawn = false
        LocalPlayer.state:set("dead", false, true)
        local spawnPoint = DeathScreen.SpawnPoints[math.random(1, #DeathScreen.SpawnPoints)]
        print(json.encode(spawnPoint))

        disableNUI()
        Wait(2000)

        SetEntityCoordsNoOffset(cache.ped, spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, false, false, false, true)
        NetworkResurrectLocalPlayer(spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, spawnPoint.coords.w, true, false)

        SetPlayerInvincible(cache.playerId, false)

        TriggerEvent("playerSpawned", spawnPoint.coords.x, spawnPoint.coords.y, spawnPoint.coords.z, spawnPoint.coords.w)
        ClearPedBloodDamage(cache.ped)
        ResetTimers()

        if adminInf then
            notify('Spawn Manager', ('You have been respawned by %s at %s'):format(adminInf, spawnPoint.name), 'success')
        else
            notify('Spawn Manager', ('You have been respawned at %s'):format(spawnPoint.name), 'success')
        end
    end
end

RegisterNetEvent('SpawnHandler:Adrevved', function (adminInf)
    if source ~= 65535 then return end

    local isDead = IsEntityDead(PlayerPedId())

    if not isDead then
        return
    end

    local coords = GetEntityCoords(PlayerPedId())
    local heading = GetEntityHeading(PlayerPedId())

    disableNUI()
    Wait(100)
    canRespawn = false
    LocalPlayer.state:set("dead", false, true)

    SetPlayerInvincible(cache.playerId, false)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, heading, 0, false)

    notify('Spawn Manager', ('You have been revived by %s'):format(adminInf), 'success')
end)

RegisterNetEvent('SpawnHandler:Respawned', function (adminInf)
    if source ~= 65535 then return end

    local isDead = IsEntityDead(PlayerPedId())

    if not isDead then
        return
    end

    respawnCharacter(adminInf)
end)

RegisterNetEvent('SpawnHandler:RespawnHandle', function(respawnTimer)
    if DeathScreen.BlurScreen then
        TriggerScreenblurFadeIn(2000)
    end
    SendNUIMessage({ type = "death", timer = respawnTimer })
    SetNuiFocus(false, false)

    while IsEntityDead(PlayerPedId()) do
        Wait(1000)
    end
    disableNUI()
end)

local function handleDeath()
    if not LocalPlayer.state.dead then
        exports.spawnmanager:setAutoSpawn(false)
        TriggerServerEvent('SpawnHandler:PlayerDied')
        LocalPlayer.state:set("dead", true, true)
    end
end

CreateThread(function()
    while true do
        local isDead = IsEntityDead(PlayerPedId())
        if isDead then
            handleDeath()
            SetPlayerInvincible(cache.playerId, true)
            SetEntityHealth(PlayerPedId(), 1)
        end
        Wait(1000)
    end
end)

AddEventHandler('onClientMapStart', function()
    exports.spawnmanager.spawnPlayer();
    Wait(1500);
    exports.spawnmanager.setAutoSpawn(false);
end)

RegisterCommand("respawn", function(source, args, rawCommand)
    local isDead = IsEntityDead(PlayerPedId())

    if not canRespawn and isDead then
        notify('Spawn Manager', 'You cannot respawn right now.', 'error')
        return
    end

    if not canRespawn and not isDead then
        notify('Spawn Manager', 'You are not dead.', 'error')
        return
    end

    if canRespawn and isDead then
        respawnCharacter()
        return
    end

    canRespawn = false
    LocalPlayer.state:set("dead", false, true)
end, false)

RegisterCommand('adrev', function(_, args, _)
    local targetId = args[1] or tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent('SpawnHandler:AdrevPlayer', targetId)
end, false)

RegisterCommand('adres', function(_, args, _)
    local targetId = args[1] or tostring(GetPlayerServerId(PlayerId()))
    TriggerServerEvent('SpawnHandler:AdresPlayer', targetId)
end, false)

TriggerEvent('chat:addSuggestion', '/adrev', 'Admin revive any player or yourself.', {
    { name="Server ID", help="The ID that pops above their head" },
})
TriggerEvent('chat:addSuggestion', '/adres', 'Admin respawn any player or yourself.', {
    { name="Server ID", help="The ID that pops above their head" },
})
TriggerEvent('chat:addSuggestion', '/respawn', 'Respawn yourself.')