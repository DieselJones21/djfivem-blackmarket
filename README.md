# djfivem-blackmarket

Custom FiveM black market with a Mount Chiliad dealer, four shop categories, cash vs black money pricing, a usable GPS item, and inventory icons.

Dirty money is the cheap rate. Cash always costs more.

## Dependencies

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_inventory](https://github.com/overextended/ox_inventory)
- ESX, QBCore, or Qbox
- [interact](https://github.com/darktrovx/interact)

`interact` is required. Ensure it starts before this resource.

## Install

1. Drop this folder into `resources` as `djfivem-blackmarket`.
2. Copy every PNG from `install/inventory_images/` into `ox_inventory/web/images/`. The shop loads icons from that folder (`nui://ox_inventory/web/images/<item>.png`), using the same files as inventory.
3. Paste the weapon and item blocks from `install/ox_inventory_items.lua` into ox_inventory:
   - weapons → `ox_inventory/data/weapons.lua`
   - items → `ox_inventory/data/items.lua`
4. Add to `server.cfg`:

```
ensure ox_lib
ensure ox_inventory
ensure interact
ensure djfivem-blackmarket
```

5. Restart, or `ensure djfivem-blackmarket`.

Custom weapon names (`WEAPON_SNAKEAP`, `WEAPON_KISSAR`, etc.) also need the matching weapon pack / meta files on your server. This resource sells those item names and ships the inventory images. It does not stream weapon models.

## Locations

- **Dealer:** Mount Chiliad lookout (`501.85, 5604.96, 797.91`)
- **GPS vendor:** Grove Street alley (`127.92, -1929.90, 20.38`) — sells only the GPS so players can find the mountain

Edit both in `config.lua`. Set `Config.GpsVendor.enabled = false` if you do not want the city contact.

## Shop

| Category | Items |
| --- | --- |
| Pistols | `WEAPON_SNAKEAP`, `WEAPON_PATRICKSEMI`, `WEAPON_DEVILAP`, `WEAPON_SINISTERRED` |
| ARs | `WEAPON_PINKWIRESMG`, `WEAPON_KISSAR`, `WEAPON_HAZARDAR`, `WEAPON_CHROMEWIRESMG` |
| Ammo | `ammo-9`, `ammo-44`, `ammo-rifle`, `ammo-shotgun`, `ammo-50` |
| BM Items | `robbery_tablet`, `lockpick`, `veh_pinkslip`, `blackmarket_gps` |

Prices live in `config.lua` as `priceBlack` (cheaper) and `priceCash` (more expensive). Change them to whatever your economy uses.

## GPS item

Using `blackmarket_gps` sets a waypoint (and optional blip) to the Chiliad dealer. The ox_inventory item fires `dj_blackmarket:useGps`. Keep `consume = 0` if the unit should be reusable.

## Config notes

- `Config.Framework = 'auto'` detects ESX / QB / Qbox
- `Config.BlockedJobs` stops police jobs from opening the shop
- `Config.Interact` uses [interact](https://github.com/darktrovx/interact) on the dealer ped
- `Config.Images` points at `ox_inventory/web/images`. Change `resource` / `folder` if your inventory path is different.
