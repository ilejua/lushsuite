# Lushsuite

A prospecting-to-outreach tool for an FX / trade finance desk. You describe who you
want to reach in plain English; it resolves that into a Lusha search, reveals verified
work emails, drafts the approach, and puts one personalised email per contact through
Gmail.

Replaces the Lusha-export → spreadsheet → Mailsuite-campaign loop with a single page.

## What it is

`index.html` is a single-file Claude Artifact. It has no server and no build step. It
runs inside the claude.ai artifact viewer and reaches Lusha and Gmail through the
viewer's **MCP capability** — calls are made with the signed-in viewer's own connector
credentials, so no API keys live in this repo or in the page.

Published at: https://claude.ai/artifact/TxU8km8LcENoXXxpgk1zgK

## Flow

| Stage | What happens | Cost |
|---|---|---|
| **1. Brief** | Free text → `sample.json` parses it into Lusha filters against the live industry / seniority / department taxonomies | Claude usage |
| **2. Prospects** | `prospecting_contact_search`, two pages of 50. Select, strike rows, edit filter chips, re-run | 1 credit / 25 results |
| **3. Reveal** | `prospecting_contact_enrich` in batches of 50, `reveal: ["emails"]` | 1 credit / email (often 0) |
| **4. Message** | `sample.json` drafts subject + body with `{{firstName}}`-style merge tokens; live per-recipient preview | Claude usage |
| **5. Send** | `create_draft` or `send_message`, one call per recipient, 900 ms apart | — |

## Search criteria

Every search is United Kingdom only — geography is fixed in `toLushaInput`, not a
filter, since no lead on this desk is outside the UK.

Large corporates are excluded by default: anyone at a company Lusha lists at 1,001+
staff or USD 500m+ revenue. Those are the nearest band boundaries below the intended
750-staff / £550m line — Lusha matches its own bands and cannot cut mid-band — and
the revenue side is USD, so £550m sits inside the 500m-1bn band either way. The
exclusion uses Lusha's `exclude` block rather than a positive size filter, so
companies with no size or revenue on file are **kept** rather than silently dropped;
`exclude` only removes known matches. Toggleable per search.

Live check on UK aviation and aerospace finance decision-makers: 943 matches
unfiltered, 370 with the exclusion on, dropping BAE Systems, QinetiQ, Smiths Group
and MAG Airports while keeping Titan Airways, AerFin and Dunlop Aircraft Tyres.

### Job titles

Departments are limited to **Finance**, **General Management** and **Operations** —
Lusha's other thirteen are not offered, since nobody in them buys a facility.

Those three still carry plenty of non-buyers, so a title guard runs over every result
(default on, and off automatically when exact titles are given):

| Kept | Dropped |
|---|---|
| CFO, Finance/Financial Director, Head of Finance, Financial Controller, Treasurer, Head of Treasury, Accounts, FP&A | Investment Director and other investor roles |
| Founder, Co-Founder, CEO, Chief Executive, Managing Director, Owner, President | Non-Executive Director, Vice President of *anything* non-finance |
| COO, Chief Operating Officer, Operations Director, Director of Manufacturing and Operations | Procurement, Supply Chain, Commercial, Strategy, Project, Manufacturing Director |

Managing Director is kept deliberately: in a UK SME it is the CEO, and dropping it
would lose most of the market.

The guard runs client-side during the page walk, so it costs no credits — the walker
simply reads further until it has a full run of on-target people. Verified against 40
real titles pulled from a live search: 21/21 kept correctly, 19/19 dropped correctly.

### Lusha filters that silently return zero

Three filters return an empty result set rather than an error when given values
Lusha does not recognise. All three were reachable from the UI and all three are now
fixed:

| Filter | Wrong value | Result | Correct form |
|---|---|---|---|
| `keywords` | `["importer"]` | **0** (vs 943) | not used at all — sector belongs in `subIndustriesIds` |
| `sizesFilterOption` | `{min:50,max:500}` | **0** | Lusha's own bands, e.g. `{min:51,max:200}` |
| `exclude.companies` | `{employeesInLinkedIn:{min:750}}` | **0** | band-aligned `sizes` / `revenues` arrays |

The brief parser is instructed never to invent a band, and any band it returns that
is not in the live list is dropped before the search runs.

## Never showing the same lead twice

Re-running a brief used to refetch pages 0 and 1 and hand back an identical list.
Three mechanisms now stop that, all persisted in `localStorage`:

- **A page cursor per query.** Each distinct filter set keeps its own position, so
  run 2 starts where run 1 stopped. Verified end to end: 12 runs of the same brief
  over a 943-match set returned 943 distinct people and **zero repeats**, fetching
  each page exactly once.
- **A seen/contacted ledger.** Everyone surfaced is remembered and softly hidden;
  everyone drafted or sent to is hidden permanently, by contact id *and* by email, so
  a person who changes employer is still not approached twice.
- **A per-company cap**, default 2. One large employer can otherwise fill a page —
  a live search for UK aviation finance returned 3 of its first 10 from one airport
  group.

The coverage strip above the list reports what each run skipped and why, and carries
the controls: max per company, *New companies only*, *Show ones I've seen*, and
*Start this search over*. A search walked to its end is flagged so later runs
short-circuit instead of burning credits rediscovering it; the flag expires after a
fortnight so records Lusha adds later still surface.

The ledger is per browser. If more than one broker works the same book, that is the
point to move it to the artifact `db` capability so the desk shares one ledger.

## Design decisions worth keeping

- **Drafts before sends.** "Create drafts" is the first-class button; "Send now" is
  gated behind typing the exact recipient count. Bulk sending is not undoable.
- **One email per recipient.** No shared BCC — each person sees only their own address,
  and replies thread normally.
- **CRM exclusions persist.** Emails or whole domains, held in `localStorage`, struck
  from every search so anyone already on the book is never approached twice.
- **Sender identification and opt-out** live in a separate signature field that is
  always appended. Under PECR, B2B marketing email to corporate subscribers is
  permitted, but GDPR still requires you to identify yourself and honour objections.
- **The draft prompt forbids rates, savings figures and guarantees** — anything that
  reads as a promise of returns. Financial promotions need the usual internal sign-off
  before they go out; this tool does not provide it.
- **Every connector error code has its own message and fix.** A lapsed token, a missing
  connector and a rate limit are three different problems with three different remedies.

## Gmail limits

Roughly 500 recipients/day on a personal Gmail, 2,000 on Workspace. The page warns
above 200 in a single run. Sudden volume spikes from a cold domain are what trip spam
filtering — warm up gradually and send from the address you want replies on.

## Branding

Palette and typography follow the Ebury brand guidelines:

| Role | Colour | Hex |
|---|---|---|
| Hero | Elegant Blue (PMS 2205) | `#74B0CA` |
| Hero | Warm Black (PMS Black 7) | `#231F20` |
| Secondary | Dark Blue | `#224862` |
| Secondary | Digital Blue | `#9FF6F3` |
| Neutral | Warm White | `#F7F4EE` |
| Neutral | Light Grey / Grey / Dark Grey / Charcoal | `#F7F7F7` `#E0E0E0` `#A3A3A3` `#737373` |

Warm White is the light ground, Warm Black the dark one; Digital Blue carries the
accent on dark, Dark Blue on light. Type is Apparat for display and Inter for body,
per the guidelines. Apparat is licensed and not redistributable, so it is named first
in the font stack and falls back to Inter — on a machine with Apparat installed it
renders as intended, everywhere else Inter (the brand's own body face) stands in.

The **ebury wordmark is deliberately not in the published artifact**. That URL is
shareable, and a page carrying the mark while composing and sending client approaches
would read as an official Ebury origination system to anyone the link reaches — a
problem on a regulated firm's financial promotions. There is a marked `LOGO SLOT` in
the header of `index.html`: drop the SVG in there for an internally hosted copy.

## On rebuilding Lusha

Not worth it. The account this was built against is an enterprise plan with ~2.6m
credits remaining and a term to March 2028 — rebuilding the data layer saves nothing
before then, and a B2B contact database is a data-acquisition business, not a feature.
The part that was genuinely worth replacing was Mailsuite, which is what this does.
