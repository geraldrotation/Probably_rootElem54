-- ProbablyEngine Rotation Packager
-- Custom Elemental Shaman Rotation
-- Created on Nov 2nd 2013 6:08 am

ProbablyEngine.rotation.register_custom(262, "rootElem54", {
  -- Combat
  -- Buffs
  { "Lightning Shield", "!player.buff" },
  { "Flametongue Weapon", "!player.enchant.mainhand" },

  -- Interrupts
  { "Wind Shear", "modifier.interrupts" },
  
  -- React to Lust

  
  -- Cooldowns
  {{
    { "120668", "player.buff(Bloodlust)" },
    { "120668", "player.buff(Time Warp)" },
    { "120668", "player.buff(Ancient Hysteria)" },
    { "120668", "player.buff(Drums of Rage)" },
    { "120668", "player.buff(114049)" },
    { "121279", "player.spell(121279).exists" },
    { "26297", "player.spell(26297).exists" },
    { "20572", "player.spell(20572).exists" },
    { "33697", "player.spell(33697).exists" },
    { "33702", "player.spell(33702).exists" },
    { "123904", "player.spell(123904).exists" },
    { "#gloves", "@rootElem.useGloves" },
    { "#76089", "@rootElem.usePot" },
  }, "modifier.cooldowns" },
  
  -- Shared Actions
  {{ -- Elemental Mastery Begins
    { "Elemental Mastery",
      {
        "player.time < 120",
        "!player.buff(Bloodlust)",
        "!player.buff(Time Warp)",
        "!player.buff(Ancient Hysteria)",
        "!player.buff(Drums of Rage)"
      },
    },
    { "Elemental Mastery",
      {
        "player.buff(Ascendance)",
        "!player.buff(Bloodlust)",
        "!player.buff(Time Warp)",
        "!player.buff(Ancient Hysteria)",
        "!player.buff(Drums of Rage)"
      },
    },
    { "Elemental Mastery",
      {
        "player.time >= 200",
        "player.buff(Ascendance).cooldown > 30",
        "!player.buff(Bloodlust)",
        "!player.buff(Time Warp)",
        "!player.buff(Ancient Hysteria)",
        "!player.buff(Drums of Rage)"
      },
    },
    { "Elemental Mastery",
      {
        "player.time >= 200",
        "player.level < 87",
        "!player.buff(Bloodlust)",
        "!player.buff(Time Warp)",
        "!player.buff(Ancient Hysteria)",
        "!player.buff(Drums of Rage)"
      },
    }
  },
    {
      "player.spell(16166).exists",
      "player.time > 15"
    }
  }, -- Elemental Mastery Ends
  
  { "Ancestral Swiftness",
    {
      "player.spell(16188).exists",
      "!player.buff(Ascendance)"
    }
  },
  
  { "Fire Elemental Totem",
    {
      "!player.totem(Fire Elemental Totem)",
      "!player.totem(Earth Elemental Totem)",
    }
  },
  
  { "Ascendance",
    {
      "modifier.multitarget",
      "modifier.cooldowns"
    }
  },
  
  {{
    { "Ascendance", "player.buff(Lava Surge)" },
    { "Ascendance", "player.time >= 60" },
    { "Ascendance", "player.buff(Bloodlust)" },
    { "Ascendance", "player.buff(Time Warp)" },
    { "Ascendance", "player.buff(Ancient Hysteria)" },
    { "Ascendance", "player.buff(Drums of Rage)" }
    -- Add TTD < 20
  },
    {
        "!player.buff(Ascendance)",
        "target.debuff(Flame Shock).duration > 15",
        "modifier.cooldowns"
    }
  }, -- End Ascendance
  
  -- AoE 
  { "Earthquake", "modifier.lshift" },
  
  {{
    { "Lava Beam" },
    { "Magma Totem", "@rootElem.openTotem(1)" },
    { "Flame Shock", "!target.debuff(Flame Shock)" },
    { "Thunderstorm", "player.mana < 80" },
    { "Chain Lightning", "player.mana > 10" },
  },
    "modifier.multitarget"
  },
  
  -- Single
  { "73680",
    {
      "player.spell(117012).exists",
      "!player.buff(114049)"
    }
  },
  { "Spiritwalkers Grace",
    {
      "player.moving",
      "player.buff(Ascendance)"
    }
  },
  { "Lava Burst",
    {
      "target.debuff(Flame Shock).duration > 1.5",
      "player.buff(Ascendance)"
    }
  },
  { "Lava Burst",
    {
      "target.debuff(Flame Shock).duration > 1.5",
      "player.buff(Lava Surge)"
    }
  },
  { "Flame Shock", "target.debuff(Flame Shock).duration < 2" },
  { "Elemental Blast", "player.spell(Elemental Blast).exists" },
  { "Earth Shock", "player.buff(Lightning Shield).count = 7" },
  -- Use Earth Shock if Lightning Shield is above 3 charges and the Flame Shock remaining duration is longer than the shock cooldown but shorter than shock cooldown + tick time interval
  -- Hard coded for now...
  { "Earth Shock",
    {
      "player.buff(Lightning Shield).count > 3",
      "target.debuff(Flame Shock).duration > 5",
      "target.debuff(Flame Shock).duration < 7"
    }
  },
  -- After the initial Ascendance, use Flame Shock pre-emptively just before Ascendance to guarantee Flame Shock staying up for the full duration of the Ascendance buff
  { "Flame Shock",
    {
      "player.time > 60",
      -- calc remains<=ascendance.cooldown+duration
    }
  },
  { "Earth Elemental Totem",
    {
      "player.spell(Fire Elemental Totem).cooldown >= 60",
      "@rootElem.openTotem(2)"
    }
  },
  { "Searing Totem",
    {
      "player.spell(Fire Elemental Totem).cooldown > 20",
      "@rootElem.openTotem(1)"
    }
  },
  { "Spiritwalkers Grace",
    {
      "player.moving",
      "player.spell(Elemental Blast).exists",
      "!player.spell(Elemental Blast).cooldown"
    }
  },
  { "Spiritwalkers Grace",
    {
      "player.moving",
      "!player.buff(Lava Surge)",
      "!player.spell(Lava Burst).cooldown"
    }
  },
  
  { "Lightning Bolt" }
},

{ -- OOC
  -- needs snapshot stats on prepot
  { "Lightning Shield", "!player.buff" },
  { "Water Walking", "!player.buff" },
  { "Flametongue Weapon", "!player.enchant.mainhand" },
  { "Ghost Wolf",
    {
      "player.moving",
      "!player.buff"
    }
  },
  { "Ghost Wolf",
    {
      "!player.moving",
      "player.buff"
    }
  },
}

)