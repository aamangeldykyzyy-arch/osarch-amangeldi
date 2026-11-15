# Ticket 2 - Computers for the second office

Prices taken: 2026-11-15 | Budget: 3,000,000 KZT, monitors included

## 1. The request as received

Daniyar K. (Director) is opening a second office and needs four computers for an accountant, a sales manager, a web developer and a designer. Budget 3,000,000 KZT for everything, monitors included, machines must last a few years. He asks whether buying the same four machines is the right approach, because "everyone says so".

## 2. The real request

**Short answer to the director's question: no. Four identical machines are wrong here.**

The four jobs load a computer in four different ways, so the same money buys the wrong thing four times:

- If all four get the cheapest of my builds (the accountant's), the total is 2,246,936 KZT, but the developer and the designer are under-powered.
- If all four get the strongest (the designer's), the total is 3,422,036 KZT, which is over the budget by 422,036.
- Even the middle build, repeated four times, costs 2,678,132 and still gives the accountant cores they never use and the designer too little.

Spread unevenly, the four needs fit under the budget: 2,863,421 KZT in total, from 561,734 to 855,509 per machine.

**What the request left out, and what I assumed in its place:**

1. **Software licences beyond the operating system.** An accountant usually needs accounting software, a designer needs Adobe tools, a developer needs an IDE. None of that is in 3,000,000 and the email does not say who pays. Assumed: bought separately by the company; I priced only the OS, as the brief requires.
2. **Everything that is not a computer or a monitor.** Keyboards, mice, UPS, a webcam and headset for sales, network cabling, delivery, and the labour of assembling four PCs. Assumed: outside these builds, covered only by the 136,579 KZT reserve (4.6 %), which is thin.
3. **"A few years".** Assumed 4-5 years of use with one upgrade at about 18 months. That is why all four use the same AM5 / DDR5 platform and keep free memory slots.
4. **VAT and invoices.** Assumed shop prices are the prices the company will pay and that the shop issues a proper invoice; to be confirmed with the vendor before ordering.
5. **The real workload of each person.** Nobody told me what the accountant, sales manager, developer and designer actually run. I assumed it from the job titles (section 3, builds.md) and these assumptions should be checked with each person.

## 3. The solution

Four builds with the load, the bottleneck and the accepted trade-off for each are in `builds.md`. Every price is a line in `budget.csv` with source and date.

| Role | Main spend | KZT |
|---|---|---|
| Accountant | 27" QHD screen, 16 GB RAM | 561,734 |
| Sales manager | 32 GB RAM | 669,533 |
| Web developer | 8 cores, 32 GB, two monitors | 776,645 |
| Designer | RTX 5050, 32 GB, 27" QHD | 855,509 |
| **Total** | | **2,863,421** |

Every machine meets the hard requirements: at least 16 GB RAM, 1 TB SSD, a licensed OS (Windows 11 Pro OEM, 87,420 KZT each, bought as a proper KZ-only pack and not as a cheap key, see section 4), and a monitor.

### Answer 1 - Which machine do I upgrade first, in 18 months?

The **designer's**, memory first: 32 GB to 64 GB. It is the one machine where I stopped short of the real need to stay within the budget; layered files and exports grow with every project, and the GPU and the board are already adequate. On this 4-slot board I would replace the 2x16 kit with 2x32 rather than add a second pair, because four modules usually lower memory speed. The cheapest upgrade in the whole set is the accountant's: a second identical 16 GB stick, because I deliberately left the slot free.

### Answer 2 - The same four as pre-built machines

The closest pre-builts I found with Kazakhstan delivery were gaming machines (alfa.kz listings, 2026-11-15): 850,653 KZT (Ryzen 5 7600X, 32 GB, 1 TB, RTX 5060), 972,175 (Ryzen 5 7500F, DDR5 32 GB, RTX 5060) and 1,030,719 (Ryzen 5 7600X, 32 GB, RTX 5060). They list no monitor and do not say whether Windows is included. Four of the cheapest is 3,402,612 KZT before monitors, which is already over the 3,000,000 budget. I found no office-class pre-built with these specifications, so this comparison is indicative; a formal quote from a vendor is still needed (TODO(author): save it in evidence/vendor-quotes/).

One listing also shows why to be careful: it pairs a Ryzen 7600X (a DDR5-only chip) with DDR4 memory, so the description itself contains an error.

What the company gains by buying pre-built:

- One warranty and one invoice for the whole machine.
- Someone else assembles and tests it, so there is no compatibility risk.
- Faster delivery and one place to call.

What the company loses by buying pre-built:

- Price: it pays for a graphics card the accountant and the sales manager will not use, four times, when only the designer needs one.
- The ability to put the money where each role needs it.
- Exact control over memory, SSD and OS licence.

What the company loses by building:

- My own labour for assembly (not priced).
- Warranty split across about ten vendors per machine.
- It needs someone to handle a failed part.

### Answer 3 - Who will complain within a month, and about what?

The **designer**, about large layered files being slow to open, save and export in Photoshop: 32 GB is enough for ordinary work and not for the biggest files. It is the trade-off I accepted in builds.md. A second, quieter complaint will be about colour (the monitor is not calibrated for print), but that is a display problem, not a performance one.

## 4. Decisions and trade-offs

- **AM5 / DDR5 for all four.** Alternative: an older DDR4 platform that I did not price, because the brief wants a few years of life and AM5 is the platform that stays on sale and can take future processors. Trade-off: DDR5 memory is the most expensive part of every build (32 GB kit 230,157 vs 99,629 for one 16 GB stick).
- **Memory as the main variable.** CPU and board are almost the same across builds (a 6-core Ryzen 5 on three, an 8-core Ryzen 7 on one), so the difference between roles is memory, monitors and one GPU.
- **Licensed OS.** I used Windows 11 Pro OEM DSP, KZ-only pack, 87,420 KZT. Alternative: marketplace listings of "Windows 11 Pro keys" at 2,000-16,000 KZT. I did not use them because I cannot show the company that they are licences; the 87,420 is 350,000 KZT over four machines, but it is the one requirement in the brief that is about legality.
- **Pre-built vs build.** Chose to build because the pre-builts I found do not fit the budget (answer 2).
- **Ryzen 7 7700 OEM + separate cooler (developer).** Alternative: boxed Ryzen 5 7600. The upgrade is only 10,659 KZT.

## 5. What I would do differently

I took most prices from shop listings shown on aggregator pages, where a "from" price can change within days, and I did not save the shops' own pages at the moment I used each price. Next time I would capture the shop page itself and its delivery terms as I choose each part, so that anyone can check the same price on the same date.

I also priced the builds before asking Daniyar what software each person runs and who pays for it, and before asking about keyboards, UPS and a headset for sales. I had to guess the workloads from the job titles. Those questions change the budget more than any component choice did, so next time I would send them first and price second.

Finally, I did not measure a real workload. A short test on an actual accountant's or designer's computer (how much memory their usual programs use together) would have replaced my assumptions about 16 GB and 32 GB with numbers.

---

*Evidence:* `evidence/` (arithmetic check, vendor price lines, PCPartPicker lists, peer check). Each file says what it proves.
