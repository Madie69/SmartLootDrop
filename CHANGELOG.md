# Changelog

## 0.1.6 Beta

- Hide zero-price items from ordinary sacrifice candidates.
- Protect Hearthstone, Camp Tent, gathering and crafting tools by name.

## 0.1.5 Beta

- Continue bag scanning when a direct link or count function is unavailable.
- Use the bag item-info record's hyperlink and alternate item/count APIs.
- Show API availability in the empty-candidate diagnostic display.

## 0.1.4 Beta

- Show bag-scan diagnostic counts when Forever returns no candidates.
- Accept either stackCount or count from the bag item-info table.

## 0.1.3 Beta

- Treat quest ID zero as a non-quest item when filtering bag candidates.
- Consider all item qualities and zero vendor prices, with clear rarity warnings.
- Display four options per page with Prev/Next for the remaining bag stacks.

## 0.1.2 Beta

- Show two read-only sacrifice candidates with current and full-stack vendor values.
- Exclude locked, quest/key, unpriced, uncommon and higher-quality items.

## 0.1.1 Beta

- Increase both visible font sizes by four points and enlarge the panel.
- Add a gold border using standard WoW textures.

## 0.1.0 Beta

- Initial independent UI frame, positioned beside Blizzard's Loot window.
- Visibility derives from LootFrame visibility and free general bag slots.
- Event refresh for loot and bag changes; no destructive controls yet.
