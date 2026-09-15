# Giving Lushsuite to someone else

A page that calls connectors runs every call on **the viewer's own account** — their
Lusha credits, their mailbox. That is the behaviour you want. The catch is how a
connector page is allowed to be shared.

## First, check the plan

claude.ai → Settings → Billing.

| Plan | Can this artifact be shared? |
|---|---|
| **Team / Enterprise** | Yes — inside the organisation, with named people or everyone in it |
| **Pro / Max** | **No.** A public link is the only sharing mechanism on these plans, and a connector page can never be public. It stays private to whoever published it |

There is no way around the Pro/Max case. It is not a setting.

## Route A — Team or Enterprise

1. Open the artifact and use the **Share** control in the page header.
2. Under *People with access*, add colleagues by email. Set each to **viewer**, or
   **editor** if they should be able to publish new versions.
3. An Owner must have **Enable artifact connectors** on, under
   claude.ai → Settings → Capabilities. Without it the page loads with no live data.
4. Each person adds their own **Lusha** and **Gmail** under Settings → Connectors.

They also need a Lusha seat of their own. The calls spend their credits, not yours.

## Route B — any plan: one copy each

Everyone publishes their own artifact from this repository. Each gets a private page
on their own connectors and their own credits.

For each person:

1. Give them access to this repo, or just send them `index.html`.
2. They install **Claude Code** or the **Claude desktop app** and sign in
   (`/login` in the CLI) on a Pro, Max, Team or Enterprise account.
3. They open the folder containing `index.html` and ask:

   ```
   Publish index.html as an artifact. It calls my Lusha and Gmail connectors —
   declare Lusha with prospecting_contact_search, prospecting_contact_enrich,
   prospecting_contact_filters, prospecting_company_filters and account_usage,
   and Gmail with create_draft and send_message. Also declare sample.
   ```

4. They add **Lusha** and **Gmail** under claude.ai → Settings → Connectors.

**This will not work by pasting the file into a normal claude.ai conversation.**
Artifacts made in a chat get a different, flat `window.claude` with no `use()`, so
none of the connector calls this page makes exist there. It has to be published from
Claude Code or the desktop app.

### What Route B costs you

The ledger and the CRM exclusion list live in each person's browser. Two brokers
working the same sector can still approach the same CFO, because neither copy knows
what the other has sent. Everything else works identically.

## Route C — if the desk needs one shared instance

If more than a couple of people use this, the per-person copies stop being good
enough: you want one shared record of who has been approached, and one place to
manage exclusions.

That is a real web app rather than an artifact — a small backend holding each user's
Lusha key and Gmail OAuth token, with a shared database for the ledger. It also lifts
the artifact sandbox's limits: an artifact can only reach its own origin, so it can
never call `api.lusha.com` directly, which is why the connector route is the only one
available inside a page.

Worth doing at roughly four or more users, or as soon as double-approaching a client
would be embarrassing.
