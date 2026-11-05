local GameConfig = {}

GameConfig.DataStoreName = "ProjectECLIPSE_PlayerData_v1"
GameConfig.AttackCooldown = 0.65
GameConfig.ComboResetSeconds = 2
GameConfig.EnemyHealth = 60
GameConfig.EnemyRespawnSeconds = 4
GameConfig.XPPerEnemy = 25
GameConfig.GoldPerEnemy = 10
GameConfig.EnergyMax = 100
GameConfig.EnergyRegenPerSecond = 8
GameConfig.Ultimate = {ChargeMax=100, ChargePerHit=8, KillBonus=12, Cooldown=25, BuffDuration=8, BasicDamageMultiplier=1.5}

GameConfig.Dungeon = {
    StageCount = 3,
    WavesPerStage = 2,
    BaseEnemiesPerWave = 2,
    ExtraEnemiesPerStage = 1,
    BossHealth = 450,
    BossDamage = 15,
    BossAttackRange = 24,
    BossAttackInterval = 3.5,
    StageClearXP = 100,
    StageClearGold = 50,
    FinalClearXP = 500,
    FinalClearGold = 250,
}

GameConfig.SkillTree = {
    MaxRank = 3,
    Nodes = {
        Power = {Name="Power Core", Description="Increases basic attack damage by 5% per rank.", Costs={100,200,350}},
        Focus = {Name="Energy Flow", Description="Reduces skill energy cost by 5% per rank.", Costs={100,200,350}},
        Mastery = {Name="Skill Mastery", Description="Increases skill damage by 8% per rank.", Costs={150,250,400}},
    },
}

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
        SkillEnergyCost = 30,
        SkillMode = "Area",
        UltimateName = "ECLIPSE BREAKER", UltimateDamage = 145, UltimateRange = 24,
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
        SkillEnergyCost = 40,
        SkillMode = "Area",
        UltimateName = "ASTRAL CATACLYSM", UltimateDamage = 125, UltimateRange = 28,
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
        SkillEnergyCost = 25,
        SkillMode = "Single",
        UltimateName = "CELESTIAL ARROW", UltimateDamage = 210, UltimateRange = 55,
        Color = Color3.fromRGB(100, 220, 150),
    },
}

return GameConfig
