SmartLootDrop 0.1.2 Beta
========================
WoW Forever, Interface 16001. Standalone, no required dependencies.

Install: extract this ZIP into your game's Interface/AddOns directory so the
result is Interface/AddOns/SmartLootDrop/SmartLootDrop.toc.

This test build retains the strict opening rule. Its companion
panel appears when the Blizzard Loot window is visible AND ordinary bag slots
have zero free spaces. It disappears when either condition stops being true.
It shows up to two low-value, priced poor/common bag stacks, with current
vendor value and potential full-stack vendor value. Quest and key categories,
locked items and items above common quality are excluded. Missing item data
is excluded. This is a read-only preview; no item can be deleted by this build.

Test: open loot with a free general bag slot; fill the last free slot while
loot remains open; close loot; reopen loot with bags full; free a general slot.
Check that both names, quantities and prices match your bags. Send screenshots
and any Lua errors from the Forever client.
