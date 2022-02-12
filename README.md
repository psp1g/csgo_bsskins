# [CS:GO] BS Skins

Sourcemod plugin for CS:GO to preview skins from inspect links or specific custom values.

This has Weapons, Knives, Gloves, and Stickers support.

## Using

```md
<Required Argument> [Optional Argument] ([Repeated] [Arguments])
```

### Inspect Links

Preview/Obtain a skin from an inspect link (Weapons, Knives, Gloves):

```md
!inspect <inspect_url>
!i <inspect_url>

# Pro tip, using '/' instead hides message from chat:

/inspect <inspect-url>
/i <inspect-url>
```

Example: (Both are the same)

```
/i steam://rungame/730/76561202255233023/+csgo_econ_action_preview%20S76561198044745785A24665550619D12294834295116039959
/i S76561198044745785A24665550619D12294834295116039959
```

### Generating (Specific Values)

You can create your ideal skin using the generate command:

```md
!gen <def-index> [paint-index] [seed] [float] ([sticker-id] [sticker-float])
!generate <def-index> [paint-index] [seed] [float] ([sticker-id] [sticker-float])
```

**\<def-index>** - This is the Item/Weapon ID [You can see a list here](https://tf2b.com/itemlist.php?gid=730)

**[paint-index]** - This is the Skin ID [You can see a list here](https://github.com/adamb70/CSGO-skin-ID-dumper/blob/master/item_index.txt)

**[seed]** - The seed/pattern for the skin. Num between: 0-999

**[float]** - The float value of the skin

--
**Weapons only:** -- (Repeat for as many stickers that can fit)

**[sticker-id]** - Sticker ID

**[sticker-float]** - Wear of sticker [You can see a list here (scroll further)](https://tf2b.com/itemlist.php?gid=730)

## Dependencies

These plugins/extensions are required for this plugin to work

- [Weapons & Knives](https://github.com/psp1g/csgo_weapons)
- [Gloves](https://github.com/psp1g/csgo_gloves)
- [Stickers](https://github.com/psp1g/csgo_stickers)

-/-

- [REST in Pawn Extension](https://github.com/ErikMinekus/sm-ripext)
- [eItems (noAPI)](https://github.com/quasemago/eItems/releases/tag/0.10_noapi)

---

Including their dependencies:

- [PTaH](https://github.com/komashchenko/PTaH)
- [MultiColors](https://github.com/Bara/Multi-Colors)

## Resources

[CSGOFloat API](https://github.com/csgofloat/inspect) - API Backend for getting skin data from inspect links from steam servers

[CSGO Item Floats from Inspect Links](https://github.com/Tewki/CSGO-Item-Floats-From-Inspect-Links) - Useful repository used to demonstrate the data stored in inspect links & what it represents, how to fetch that data yourself

[CSGO Steam Item Protobufs](https://github.com/SteamRE/SteamKit/blob/f94c56ce371b2ec76794ed284b80582bae47cea4/Resources/Protobufs/csgo/cstrike15_gcmessages.proto#L657-L701) - Officially used Valve bufs

## Warning

**In the past, valve has banned GSLTs for use of similar & dependant plugins. They have stopped for some reason, but at any time they could ban your GSLT for use of this plugin.**