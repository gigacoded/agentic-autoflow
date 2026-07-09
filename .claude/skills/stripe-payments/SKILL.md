---
name: stripe-payments
description: Integrate and modify Stripe payments in this stack — Checkout Sessions and webhooks running inside Convex actions/http routes, fronted by TanStack Start. Use when adding payments, subscriptions, checkout, billing portals, or webhook handlers, or when payment state in the app disagrees with the Stripe Dashboard. Covers key handling, webhook verification, idempotency, and test-mode verification. For general Convex patterns see convex-backend-dev.
---

# Stripe Payments (Convex + TanStack Start)

**Never trust the client with money.** Prices, amounts, currencies, and
entitlements are decided server-side from data the server already holds. A
request from the browser may carry a product/price ID at most — never an
amount.

## Where each piece lives

| Piece | Location | Why |
|---|---|---|
| Secret key (`STRIPE_SECRET_KEY`) | Convex env: `npx convex env set STRIPE_SECRET_KEY sk_...` | Never in client bundle; never `VITE_`-prefixed |
| Webhook secret (`STRIPE_WEBHOOK_SECRET`) | Convex env | Same |
| Publishable key | Client env (`VITE_STRIPE_PUBLISHABLE_KEY`) | Safe to expose |
| Checkout Session creation | Convex action with `"use node"` (the Stripe SDK needs Node) | Amount decided server-side |
| Webhook endpoint | `convex/http.ts` httpAction, e.g. `/stripe/webhook` | Raw body access for signature check |
| Payment/subscription state | Convex table (e.g. `stripeCustomers`, `subscriptions`) keyed by `stripeCustomerId` | App reads Convex; Stripe stays source of truth, webhooks sync it |
| Success/cancel pages | TanStack Start routes | Display only — never fulfill here |

## Checkout flow (the default)

1. Client calls a Convex action (or TanStack server function that calls it)
   with a product/price identifier only.
2. The action authenticates the user, looks up or creates the Stripe
   customer (store `stripeCustomerId` on the user), and creates a Checkout
   Session with the server-decided price, `success_url`/`cancel_url` back to
   TanStack routes, and `client_reference_id` or `metadata.userId` set.
3. Return only the session URL; client redirects to it.
4. **Fulfillment happens in the webhook handler, never on the success page.**
   The success page is cosmetic — a user can open that URL without paying.

## Webhook handler rules

In `convex/http.ts`:

1. Read the RAW body (`await request.text()`) — parsing JSON first breaks
   signature verification.
2. Verify the signature with the webhook secret
   (`stripe.webhooks.constructEventAsync(body, sig, secret)`); on failure
   return 400 and do nothing else.
3. Idempotency: store processed `event.id`s in a Convex table and skip
   duplicates — Stripe retries deliveries.
4. Handle the minimum set and ignore the rest:
   `checkout.session.completed` (fulfill), `customer.subscription.updated` /
   `.deleted` (sync status), `invoice.payment_failed` (flag account).
5. Do the work via `internal.*` mutations, return 200 quickly. Never call
   `api.*` from the handler.

## Idempotency and race rules

- Pass an idempotency key when creating Stripe objects from retryable code
  (e.g. `{ idempotencyKey: userId + ":" + purpose }`).
- Webhooks can arrive out of order — handlers set absolute state from the
  event's object (`subscription.status`), never increment/toggle.
- The app never computes entitlement from a successful redirect, only from
  the Convex record that the webhook wrote.

## Test-mode verification (before reporting done)

1. Use test keys (`sk_test_...`) against the dev deployment — confirm with
   `mcp__convex__envGet STRIPE_SECRET_KEY` that the value starts `sk_test_`.
2. Forward webhooks locally:
   `stripe listen --forward-to <convex-site-url>/stripe/webhook`
   (the Convex HTTP URL is the `.convex.site` one, not `.convex.cloud`).
3. Exercise the real flow in the browser (see `verify-frontend-change`):
   checkout with card `4242 4242 4242 4242`, any future expiry, any CVC.
   For failure paths use `4000 0000 0000 0002` (declined).
4. Verify the webhook wrote the Convex record: read the table with
   `mcp__convex__data`, check `mcp__convex__logs` for the handler run
   (see `verify-backend-change`).
5. Cross-check the Stripe Dashboard (test mode) shows the same object state
   the Convex table claims.

Report `Verified:` naming the card/flow exercised and the Convex record
observed, or `Unverified: ... because <reason>` (e.g. no test keys in this
environment).

## When app state disagrees with Stripe

Stripe is the source of truth. Debug in this order: (1) did the event reach
the handler (`mcp__convex__logs`, Dashboard → Developers → Events →
delivery attempts)? (2) did signature verification pass? (3) did the
idempotency table wrongly mark it processed? (4) did the handler set state
from a stale event? Re-sync by fetching the object from Stripe and writing
it, not by hand-editing the row.
