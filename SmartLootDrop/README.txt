SmartLootDrop 0.1.4 Beta
========================
WoW Forever, Interface 16001. Standalone, no required dependencies.

Install: extract this ZIP into your game's Interface/AddOns directory so the
result is Interface/AddOns/SmartLootDrop/SmartLootDrop.toc.

This test build retains the strict opening rule. Its companion
panel appears when the Blizzard Loot window is visible AND ordinary bag slots
have zero free spaces. It disappears when either condition stops being true.
It lists vendor-priced bag stacks of all qualities, four at a time, sorted by
current stack vendor value. Prev/Next shows more candidates. It also shows
potential full-stack vendor value and labels the quality of each item.
Higher-quality choices are marked CAUTION. Quest and key categories and locked
items are excluded. Missing item data is excluded. This is a read-only preview;
no item can be deleted by this build.
Quest ID zero is treated as a non-quest item.
If there are no candidates, the panel displays bag-scan counts for debugging.

Test: open loot with a free general bag slot; fill the last free slot while
loot remains open; close loot; reopen loot with bags full; free a general slot.
Check that both names, quantities and prices match your bags. Send screenshots
and any Lua errors from the Forever client.
