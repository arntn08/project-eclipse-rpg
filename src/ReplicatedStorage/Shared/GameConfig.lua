local GameConfig = {}

GameConfig.DataStoreName = "ProjectECLIPSE_PlayerData_v1"
GameConfig.MaxAttackDistance = 16
GameConfig.AttackCooldown = 0.65
GameConfig.EnemyHealth = 60
GameConfig.EnemyRespawnSeconds = 4
GameConfig.XPPerEnemy = 25
GameConfig.GoldPerEnemy = 10

GameConfig.Classes = {
    Swordsman = {
        DisplayName = "Swordsman",
        Description = "A close-range fighter with balanced power and defense.",
        Damage = 25,
        Range = 12,
        Color = Color3.fromRGB(70, 170, 255),
    },
    Mage = {
        DisplayName = "Mage",
        Description = "A ranged spellcaster who attacks from a safer distance.",
        Damage = 20,
        Range = 16,
        Color = Color3.fromRGB(190, 110, 255),
    },
    Archer = {
        DisplayName = "Archer",
        Description = "A swift ranged attacker with precise strikes.",
        Damage = 18,
        Range = 16,
        Color = Color3.fromRGB(100, 220, 150),
    },
}

return GameConfig
