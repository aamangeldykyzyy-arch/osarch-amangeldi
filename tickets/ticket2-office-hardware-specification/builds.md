# Four builds, with reasoning

Prices: KZT, taken 2026-11-15 (see budget.csv for model, source and date of every line).
All four: AM5 platform, MSI PRO B650M-P (DDR5, mATX), Kingston NV3 1 TB NVMe, MSI MAG A550BN 550 W, Deepcool CC360 case, Windows 11 Pro OEM (licensed, KZ-only DSP pack).

## Build 1 - accountant

**Load:** spreadsheets and accounting software, bank and e-government portals in a browser, PDFs. Many hours a day reading dense tables. Low CPU, but a mistake or a crash costs real money.

**Bottleneck:** the screen, not the processor. A 1080p monitor means constant scrolling through wide tables; memory only matters when several large workbooks, the browser and the accounting client are open together.

**Trade-off:** one 16 GB stick (the minimum in the brief) instead of 32 GB. That saves 130,528 KZT (230,157 for the 32 GB kit vs 99,629 for one 16 GB stick). I spent part of it on a 27" QHD monitor (+22,729 vs the FHD panel used for sales) and left the second memory slot free. Cost of the choice: single-channel memory, which is slower but irrelevant for this load, and this is the machine with the cheapest upgrade (add a second identical stick).

**Alternative considered:** 32 GB for the accountant. On paper it fits (total would be 2,993,949), but it leaves 6,051 KZT of reserve for everything the director did not mention. Rejected.

**Total:** 561,734 KZT (budget.csv, role = accountant).

## Build 2 - sales manager

**Load:** CRM in a browser with many tabs, Excel, several hours of video calls a day, usually all at once.

**Bottleneck:** memory. The danger is not a slow calculation but swapping to disk in the middle of a customer call. CPU sits mostly idle.

**Trade-off:** Ryzen 5 7600 (6 cores) rather than a Ryzen 7, and the money went into a 32 GB kit. Monitor is a 27" FHD IPS panel (73,724), not QHD: good enough for a CRM and screen sharing, 22,729 cheaper than the QHD panel.

**Alternative considered:** 16 GB plus Ryzen 7 7700. Rejected: the extra cores would idle, and 16 GB is exactly where this role starts to hurt.

**Not included:** webcam and headset. For this role they matter more than any CPU. Covered only by the reserve.

**Total:** 669,533 KZT (role = sales).

## Build 3 - web developer

**Load:** IDE, local services or containers, several browsers with developer tools open, builds and tests, sometimes a virtual machine.

**Bottleneck:** memory and parallel CPU threads when builds and containers run at the same time; second, screen space (code on one screen, browser or docs on the other).

**Trade-off:** Ryzen 7 7700 (8 cores) bought as an OEM chip with a separate Deepcool AG400 cooler, which costs only 10,659 more than the boxed Ryzen 5 7600. Second monitor (QHD + FHD) instead of one: +73,724. Stayed on 32 GB and on integrated graphics; this role does not need a discrete GPU.

**Alternative considered:** Ryzen 5 7600 and a single monitor. Saves 84,383 KZT. Rejected: a second screen pays back every day, and cores matter only for this role.

**Total:** 776,645 KZT (role = web_developer).

## Build 4 - designer

**Load:** Photoshop, Illustrator, Figma; large layered files, exports, colour-critical work.

**Bottleneck:** memory first (big files), then the GPU and the display.

**Trade-off:** 167,281 KZT on a discrete GeForce RTX 5050 (8 GB) and a 27" QHD monitor, but only 32 GB of RAM and a monitor that is not factory-calibrated for colour. The budget did not allow 64 GB on top of the GPU.

**Alternative considered:** no discrete GPU (saves 167,281, integrated graphics only) and put the money toward 64 GB later. Kept as the fallback if the director cuts the budget; the GPU slot stays free either way.

**Total:** 855,509 KZT (role = designer).

## Sum

| Role | KZT |
|---|---|
| Accountant | 561,734 |
| Sales manager | 669,533 |
| Web developer | 776,645 |
| Designer | 855,509 |
| **Total** | **2,863,421** |
| Reserve (of 3,000,000) | 136,579 (4.6 %) |

Check: evidence/arithmetic-check.txt .
