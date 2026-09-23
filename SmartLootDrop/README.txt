SmartLootDrop 0.1.1 Beta
========================
WoW Forever, Interface 16001. Standalone, no required dependencies.

Install: extract this ZIP into your game's Interface/AddOns directory so the
result is Interface/AddOns/SmartLootDrop/SmartLootDrop.toc.

This first test build checks the strict opening rule only. Its small companion
panel appears when the Blizzard Loot window is visible AND ordinary bag slots
have zero free spaces. It disappears when either condition stops being true.
The panel has larger text and a gold border.
It does not yet inspect, recommend, or destroy any items. No item can be
deleted by this build.

Test: open loot with a free general bag slot; fill the last free slot while
loot remains open; close loot; reopen loot with bags full; free a general slot.
Send screenshots and any Lua errors from the Forever client.
