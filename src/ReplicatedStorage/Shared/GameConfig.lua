local GameConfig = {}

GameConfig.DataStoreName = "ProjectECLIPSE_PlayerData_v1"
GameConfig.AttackCooldown = 0.65
GameConfig.ComboResetSeconds = 2
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
        SkillName = "SHADOW SPIN",
        SkillDescription = "A powerful spinning strike around you.",
        SkillDamage = 48,
        SkillRange = 15,
        SkillCooldown = 8,
        SkillMode = "Area",
        Color = Color3.fromRGB(70, 170, 255),
    },
    Mage = {
        DisplayName = "Mage",
        Description = "A ranged spellcaster who attacks from a safer distance.",
        Damage = 20,
        Range = 16,
        SkillName = "ARCANE NOVA",
        SkillDescription = "Release an arcane burst that hits nearby enemies.",
        SkillDamage = 42,
        SkillRange = 21,
        SkillCooldown = 10,
        SkillMode = "Area",
        Color = Color3.fromRGB(190, 110, 255),
    },
    Archer = {
        DisplayName = "Archer",
        Description = "A swift ranged attacker with precise strikes.",
        Damage = 18,
        Range = 16,
        SkillName = "PIERCING SHOT",
        SkillDescription = "Fire a focused shot at the nearest enemy.",
        SkillDamage = 58,
        SkillRange = 30,
        SkillCooldown = 7,
        SkillMode = "Single",
        Color = Color3.fromRGB(100, 220, 150),
    },
}

return GameConfig
