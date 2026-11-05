local ItemConfig = {}
ItemConfig.Items = {
 TrainingBlade={Name="Training Blade",Slot="Weapon",Rarity="Common",Attack=4,Defense=0,Level=1,SellValue=8,Description="A dependable starter blade."},
 AzureEdge={Name="Azure Edge",Slot="Weapon",Rarity="Rare",Attack=12,Defense=0,Level=3,SellValue=45,Description="A blade humming with blue energy."},
 ShadowFang={Name="Shadow Fang",Slot="Weapon",Rarity="Epic",Attack=22,Defense=0,Level=7,SellValue=120,Description="Forged in a shadow rift."},
 NoviceArmor={Name="Novice Armor",Slot="Armor",Rarity="Common",Attack=0,Defense=5,Level=1,SellValue=8,Description="Light armor for new hunters."},
 GuardianMail={Name="Guardian Mail",Slot="Armor",Rarity="Rare",Attack=0,Defense=12,Level=3,SellValue=45,Description="Armor carrying a faint aura."},
 EclipsePlate={Name="Eclipse Plate",Slot="Armor",Rarity="Epic",Attack=0,Defense=22,Level=7,SellValue=120,Description="Armor shaped by an eclipse."},
}
ItemConfig.DropTables = {
 Normal={{Id="TrainingBlade",Chance=25},{Id="NoviceArmor",Chance=25},{Id="AzureEdge",Chance=8},{Id="GuardianMail",Chance=8}},
 Boss={{Id="AzureEdge",Chance=35},{Id="GuardianMail",Chance=35},{Id="ShadowFang",Chance=15},{Id="EclipsePlate",Chance=15}},
}
return ItemConfig
