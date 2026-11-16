---
name: codebase-standard
description: "The house standard for Next.js or SvelteKit 2 / Svelte 5 projects with Tailwind and strict TypeScript: the stack, one folder per component (index/styles/types/static/functions), a single globals.css, tw() class lists, design tokens, the @shadcn/lint rules and the checks. Use when writing, moving or reviewing code in a web project, and when starting one."
---

# Codebase standard

## Stack
- Next.js (App Router, latest), React 19, TypeScript `strict`, `@/*` → project root.
- Tailwind CSS v4 via `@tailwindcss/postcss`. There is no tailwind.config: tokens live in `app/globals.css`.
- Icons come from `lucide-react` only, imported by their `…Icon` names (`ArrowUpRightIcon`). Give each one `size` and `strokeWidth`, and `aria-hidden="true"` when it is decorative. No hand-written SVG icons, no second icon set.
- pnpm, Prettier (2 spaces), ESLint 9 flat config: `eslint-config-next/core-web-vitals` + `@shadcn/lint`.
- zod at every trust boundary: one schema, shared by the form and the route that receives it.
- Every photograph goes through the `Photo` primitive (`components/ui/Photo`; SvelteKit `src/lib/components/ui/Photo`): a loading veil with the image's blur and a sweeping light, then a fade-in. Never a bare `next/image` or `<img>` for a photograph. Read the `photo` skill (`~/.claude/skills/photo/SKILL.md`) before adding or reviewing images: it has the code, the tokens it needs and the blur pipeline.
- Only when the project needs them: GSAP (+ Lenis) for motion, Resend + React Email for mail.
- No new dependency for what a few lines can do.

## SvelteKit / Svelte 5

For Svelte projects, this section replaces the React/Next-specific stack, route, component and tooling instructions below. Keep the shared organization, token and security conventions.

### Version reference

Prefer the user's maintained Svelte 5 projects in their workspace when choosing versions, taking the most recently maintained one as the reference. Inspect both manifests and lockfiles: a declared range is not the installed version. Do not use a prerelease-Svelte prototype or a Svelte 3/4 project as the new-project baseline.

Manifest baseline observed on 10 November 2026:

| Package | Reference version |
| --- | --- |
| `svelte` | `^5.54.0` |
| `@sveltejs/kit` | `^2.50.2` |
| `vite` | `^7.3.1` |
| `@sveltejs/vite-plugin-svelte` | `6.2.4` |
| `@sveltejs/adapter-node` | `^5.2.9`, when a Node server is needed |
| `typescript` | `^5.9.3` |
| `svelte-check` | `^4.4.2` |
| `bits-ui` | `2.16.5`; compatible stable 2.x updates are acceptable |
| `@types/node` | `^24.0.3` |
| Package manager | pnpm 9 |

Keep SvelteKit, Svelte, Vite and the Svelte Vite plugin compatible as a group, checking their package peer dependencies. Preserve a compatible lockfile; do not downgrade newer compatible patch/minor versions just to reproduce an older reference lock. Reinspect the local reference when revising this baseline rather than assuming these versions remain current. Use a supported Node release satisfying the dependencies' engines.

Some existing Svelte projects still use Tailwind 3. Existing projects keep their styling generation unless a migration is requested. New projects following this house standard use Tailwind 4 through `@tailwindcss/vite`, one `src/routes/globals.css`, `tailwind-merge` 3 and compatible shadcn-svelte primitives. Do not copy Tailwind 3 utilities/plugins, prerelease UI packages, or both old and new Lucide packages into that stack. Use one `@lucide/svelte` icon package.

### Svelte conventions

- Use Svelte 5 runes (`$props`, `$state`, `$derived`), snippets and event attributes. Effects are only for external synchronization and return their cleanup; rune helpers that need a module live in `.svelte.ts` files.
- Application components use PascalCase folders with `index.svelte` and sibling `styles.ts`, `types.ts`, `static.ts`, `functions.ts` only as needed. `class={styles.root}` consumes static `tw()` lists. Vendored shadcn-svelte multipart primitives retain their native filenames and variants under `src/lib/components/ui`; do not mechanically rewrite them into the application folder scheme.
- Keep native SvelteKit route filenames (`+page.svelte`, `+layout.svelte`, `+page.server.ts`, `+layout.server.ts`, `+server.ts`, `+error.svelte`) and `$lib` imports. Server code stays in `src/lib/server`; pure shared business rules belong in `src/lib/domain`. No Next.js or React runtime patterns in Svelte modules.
- Compose the house neutral dashboard (see Dashboard and backend below) using shadcn-svelte/Bits UI. Translate the visual system, not its React implementation or dependencies. Follow each project's language and breakpoint requirements.
- Use SvelteKit server loads, form actions and progressive enhancement; authorize each server read/write. Shared runes must not hold per-user server state. Keep secrets server-only. Use the local Docker PostgreSQL/Make operating pattern when persistence is needed, adapting migration commands to the project's actual database library.
- Keep strict TypeScript, Prettier with `prettier-plugin-svelte`, and Svelte-aware ESLint. Configure TypeScript parsing for both `.svelte` and `.svelte.ts`; recognize `$lib/components/ui` and `tw()` in shadcn lint. If the linter cannot resolve imported `styles.ts` constants, document the narrow exception instead of moving classes back into markup.
- `typecheck` is `svelte-kit sync && svelte-check --tsconfig ./tsconfig.json`; `dev` runs Vite and `make dev` calls it. Setup/dev must not trigger lint, checks, builds or tests. Do not run builds or tests without the user's explicit request, and do not add CI that bypasses this restriction.

## Structure
Every component is a folder, and each kind of thing in it has its own file:

| File         | Holds                                          |
| ------------ | ---------------------------------------------- |
| index.tsx    | The component and its markup, nothing else     |
| styles.ts    | Every class list, written as `tw("…")`         |
| types.ts     | Types, props included (`XProps`)               |
| static.ts    | Constants: lists, option sets, copy, timings   |
| functions.ts | Helpers, hooks, the setup code effects run     |

- A file exists only when there is something to put in it.
- Route files keep their Next.js names (`page.tsx`, `layout.tsx`, `route.ts`, `not-found.tsx`) and take the same sibling files. `page.tsx` composes sections and sets metadata. It holds no class strings, constants, types or helpers.
- Who uses a thing decides where it lives:
  - one page → that page's folder (`app/contact/ContactForm/`, or `app/(group)/components/Hero/` inside a route group)
  - several pages → `components/`
  - root-layout chrome → `components/layout/`; motion → `components/motion/`; primitives with variants → `components/ui/`
  - a function used by one route sits beside it. Once several routes share it, it moves up to their common folder (`app/functions.ts`, `app/api/functions.ts`) or to `lib/`.
  - Move a thing when its second user appears, not before.
- Site copy and data shared across pages go in `content/` (JSON or TS, types in `content/types.ts`, re-exported from `content/index.ts`). Copy that only one component uses goes in that component's `static.ts`.
- The root route files share one `app/styles.ts` and one `app/types.ts`, sectioned with `// layout.tsx`-style comments.

## Styling
- One CSS file: `app/globals.css`. No CSS modules, no other stylesheets. Its sections, in order:
  1. `@import "tailwindcss"`
  2. `@theme inline`: colour tokens mapped to CSS variables
  3. `@theme`: fonts, tracking, leading, type scale, spacing, easing, keyframes
  4. `:root` and `:root[data-theme="dark"]` variables
  5. `@font-face`
  6. `@layer base`
  7. `@utility`
  8. `@layer components`: only classes that more than one component uses

  Everything else is utilities in place.
- `lib/tw.ts`: `export const tw = (...classes: string[]) => classes.join(" ");`. Every `styles.ts` writes through it, so ESLint (`settings.shadcn.mergeFunctions: ["tw"]`) and the editor (`.vscode/settings.json` → `"tailwindCSS.classFunctions": ["tw"]`) can read the classes.
- `styles.ts` exports one const per element, named for its role (`root`, `trigger`, `panel`). Long lists are split across arguments by concern or breakpoint. Variants are objects (`variants = { accent: tw("…") }`). Use them as `import * as styles from "./styles"` → `className={styles.panel}`.
- Class strings are static. State goes in a data attribute (`data-open={open}`) and the styles read it (`group-data-[open=true]:visible`). No ternaries in `className`.
- Layout is flex first: `flex`, `flex-col`, `justify-*`, `items-*`, `gap-*`, `flex-wrap`, `basis-*`. `grid place-items-center` on one child is `flex items-center justify-center`; one column spaced with `grid gap-*` is `flex flex-col gap-*`. Use grid only when flex can't do it, and say which case in a one-line comment on it:
  - items that line up on both axes (real rows and columns, like a card grid or a form whose fields share columns)
  - layers stacked in one cell (`col-start-1 row-start-1`)
  - a column that keeps its share while the item in it is narrower (`max-w-*`): flex hands the leftover to the neighbour
  - shares between padded items (`1.2fr 0.8fr`): flex counts each item's padding before it shares out the rest
  - equal parts as wide as the widest content, in a box sized by its content (a two-way switch whose thumb slides exactly one half)
  - a middle item centred between two that keep only their own width (`grid-cols-[1fr_auto_1fr]`)
  - a height animated open from nothing (`grid-rows-[0fr]` → `grid-rows-[1fr]`)
  - Writing a split in flex: `minmax(0, n fr)` is `flex-[n] min-w-0`; an item with a set width beside a growing one takes `shrink-0`, as a grid's `auto` column never shrinks; a row that stacks on phones (`max-md:flex-col`) takes `max-md:items-stretch` if it centres items, since `items-center` then centres across the width.
- Dynamic values go through a CSS custom property: `style={{ "--delay": `${ms}ms` } as CSSProperties}`, read in a class (`delay-(--delay)`). No other inline styles.
- Colours are tokens only (`bg-surface`, `text-foreground`, `text-quiet`, `border-rule`, `text-accent`), each defined for both themes. No hex, rgb or Tailwind palette colours in components.
- Type, spacing, colour, radius, shadow and easing come from Tailwind's scale or an `@theme` token. When a new value is needed, add a token.
  - Brackets are for structure only: grid tracks, sizes, offsets, transforms, `em` shares of the type size.
  - A share of the parent is a fraction (`w-1/2`). Only padding and gap take a bracketed `%`.
  - Margin and tracking never take brackets.
- A `components/ui` primitive is placed by its caller (margin, width). How it looks is a variant inside it.
- Classes that are only JS hooks (no CSS of their own) go on the `no-unknown-classes` allow list, with a comment naming the code that uses them.
- One breakpoint direction per project: desktop-first, with `max-lg:` and `max-md:`.
- `prefers-reduced-motion` is handled once, globally, in `@layer base`.

## TypeScript & React
- Types are imported with `import type`. Components are default exports; a folder that exports several primitives (`Button`, `ButtonLink`) uses named exports.
- Import order: packages, `@/` imports, local components, then `./functions`, `./static`, `./styles`, `./types`.
- Server components by default. `"use client"` goes only where state, effects or browser APIs are needed, as low in the tree as possible.
- Effect setup lives in `functions.ts` and returns its own cleanup: `useEffect(() => closeOnLeave(open, rootRef, setOpen), [open])`.
- Accessibility basics always: a skip link, `aria-*` on custom controls, keyboard support, visible focus, `alt` text.
- API routes trust nothing:
  - check the origin
  - cap the body size
  - rate-limit
  - re-validate with the shared zod schema
  - log failures as `console.error("[route] …", error)`

## Comments
- Each export gets a one-line `/** … */` saying what it is, in plain words.
- Inline comments say why, never what. No commented-out code.

## Lint config (`eslint.config.mjs`)
```js
import { plugin as shadcn } from "@shadcn/lint";
import nextVitals from "eslint-config-next/core-web-vitals";

// Classes with no CSS of their own: name the code that finds elements by them.
const jsHooks = [];
const margin = ["m", "mx", "my", "mt", "mr", "mb", "ml", "ms", "me"];
// Tailwind writes a share of these as a fraction (w-1/2, top-1/20, -translate-y-3/2).
const fraction =
  "w h size min-w max-w min-h max-h basis inset inset-x inset-y top right bottom left start end translate translate-x translate-y"
    .split(" ")
    .map((group) => `${group}-[*%]`);

export default [
  ...nextVitals,
  {
    plugins: { shadcn },
    settings: { shadcn: { mergeFunctions: ["tw"] } },
    rules: {
      "react-hooks/refs": "warn",
      "react-hooks/set-state-in-effect": "warn",
      "shadcn/no-arbitrary-values": [
        "error",
        {
          allow: ["layout", "transition", "*-[*%]", "*-[*em]"],
          deny: [...margin, "tracking", ...fraction],
        },
      ],
      "shadcn/no-raw-colors": "error",
      "shadcn/no-inline-styles": "error",
      "shadcn/no-unknown-classes": ["error", { allow: jsHooks }],
      "shadcn/no-restyle": ["error", { allow: ["layout"] }],
      "shadcn/require-static-classes": "error",
    },
  },
  {
    files: ["components/ui/**"],
    rules: { "shadcn/no-restyle": "off", "shadcn/require-static-classes": "off" },
  },
];
```
React Email templates need px, so a project that has them turns `no-arbitrary-values` off for `emails/**`.

## Checks
- Tests are plain Node scripts: `scripts/check-*.mjs` using `node:assert/strict`, run by `pnpm test` (`node --test "scripts/check-*.mjs"`). No test framework.
- Nothing is done until `pnpm lint`, `pnpm exec tsc --noEmit`, `pnpm test` and `pnpm build` pass. GitHub Actions runs the same four on pull requests and pushes to main, after `pnpm install --frozen-lockfile`.
- A new project starts by copying in `lib/tw.ts`, the lint config above, `.vscode/settings.json`, `.prettierrc` (`tabWidth: 2`), the CI workflow, a `globals.css` laid out as above (with the `photo` skill's tokens), `components/ui/Photo` from the `photo` skill, and the Makefile below.

## Dashboard and backend (projects with an admin)
The canonical admin is the house reference project's `src/app/dashboard/**`. A new project copies it and changes only its nav, pages and brand; it never restyles it.
- Own root layout at `app/dashboard/layout.tsx`: `<html data-app="dashboard" data-theme=…>`, Geist + Geist Mono via next/font (`--font-geist`, `--font-geist-mono` → `--font-ui`, `--font-ui-mono`), theme and sidebar state from cookies so nothing flashes, `requirePageUser([...])` first. English only. `robots: noindex`.
- `globals.css` carries the `:root[data-app="dashboard"]` and `[data-theme="dark"]` token blocks (shadcn's neutral oklch set + `--sidebar-*`, `--chart-1..5`, `--radius: 0.625rem`) and `@custom-variant dark` scoped to that `<html>`; the site never uses `dark:`.
- Primitives live in `app/dashboard/components/ui/*` (shadcn ports in the folder layout above: AlertDialog, Avatar, Badge, Breadcrumb, Button, Calendar, Card, Chart, Checkbox, Command, Dialog, DropdownMenu, Form, FormFields, Input, Label, Popover, Select, Separator, Sheet, Sidebar, Skeleton, Switch, Table, Tabs, Textarea, Toaster, Tooltip). Shared pieces beside them: AppSidebar, SiteHeader (breadcrumb, ⌘K, theme), CommandPalette, DataTable (+ SortHeader, Toolbar, Pagination), RecordSheet, SaveBar, PageHeader, StatCard, StatusBadge, EmptyState, ConfirmAction, ThemeToggle.
- Dependencies that come with it: `@radix-ui/react-{alert-dialog,checkbox,dialog,dropdown-menu,label,popover,select,slot,switch,tabs,tooltip}`, `@tanstack/react-table`, `cmdk`, `sonner`, `recharts`, `react-hook-form` + `@hookform/resolvers`, `react-day-picker`.
- ESLint: `settings.shadcn.componentImports: ["^@/app/dashboard/components/ui(/|$)"]`, and `files: ["components/ui/**", "app/dashboard/components/ui/**"]` get `no-restyle` and `require-static-classes` off.
- Every mutation is a server action in `server/admin/*.ts` returning `ActionResult` (`{ ok, message, fieldErrors? }`); the client runs it through `useAction()` (`components/ui/Toaster/functions.ts`): toast from the `results` code table in `app/dashboard/static.ts`, field errors onto the form, `router.refresh()`.
- Backend standard, copied from the reference project's `src/server`: `security/http.ts` (`RequestError`, `assertOrigin`/`assertActionOrigin`, `clientIp` from `TRUSTED_IP_HEADER`, `readJson`/`readBody` caps, `assertId`/`assertSlug`, `apiError`), `security/rate-limit.ts` (HMAC-keyed `RateLimitBucket` in Postgres), `security/passwords.ts` (scrypt, constant time), `auth/{config,session}.ts` (NextAuth credentials, JWT, `sessionVersion`, `requireUser`/`requirePageUser`), `media/storage.ts` (sharp → WebP, R2 via `aws4fetch` or `storage/` locally), `email/send.ts` (outbox + Resend), `proxy.ts` (CSP nonce, no-store on private routes), Prisma 7 + `@prisma/adapter-pg` on Neon.
- Roles `ADMIN | STAFF | …`. "Delete" for STAFF hides the row (`removedAt`, `removedById`, status → ARCHIVED; it answers NOT_FOUND to staff afterwards); ADMIN deletes for good and can see and restore removed rows. Every write audits (`AuditEvent`). One `takeAway(id, user)` per entity.
- Bilingual rows carry one column per language (`nameSq`, `nameEn`), both filled; editors show them side by side.
- Caching is Next 16's Cache Components (`cacheComponents: true` in `next.config.ts`): public loaders in `server/*.ts` are `async` functions opening with `"use cache"`, `cacheTag("shop" | "blog" | "settings")` and an explicit `cacheLife(profile)`; never `unstable_cache`. Server actions invalidate with `updateTag(tag)`, route handlers with `revalidateTag(tag, "max" | { expire: 0 })`. Nothing in a render path reads the clock: a page that needs the time awaits `requestTime()` (`server/clock.ts`, `connection()` then `new Date()`) and hands it down; client tables show relative times through a `useSyncExternalStore` component (`Ago`) whose server snapshot is null. Segments that read the request at the top (session, language cookie, cart) carry `export const instant = false` until they are split behind `<Suspense>`.

### Local database (every project with Prisma)
PostgreSQL runs in Docker, never installed on the machine, from a `compose.yaml` at the root; production is Neon. `scripts/setup-env.ts` (`make env`, part of `make setup`) writes `.env.local` from `.env.example` with a random `POSTGRES_PASSWORD`, `NEXTAUTH_SECRET` and the matching `DATABASE_URL`. Each project takes its own `POSTGRES_PORT` in `.env.local` (5432, 5433, 5434…), so sibling projects run side by side.
```yaml
services:
  postgres:
    image: postgres:17-alpine
    environment:
      POSTGRES_USER: <project>
      POSTGRES_DB: <project>
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:?Set POSTGRES_PASSWORD in .env.local}
    ports:
      - "127.0.0.1:${POSTGRES_PORT:-5432}:5432"
    volumes:
      - <project>-postgres:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U <project> -d <project>"]
      interval: 5s
      timeout: 5s
      retries: 10
volumes:
  <project>-postgres:
```
The Makefile adds, on top of the base below, `COMPOSE := docker compose --env-file .env.local` and these targets, all named the same in every project: `setup` (install + `setup:env` + `db:generate`), `env`, `generate`, `db-up` (`$(COMPOSE) up -d --wait postgres`, after `env`), `db-down` (`$(COMPOSE) down`, data kept in the volume), `db-setup` (`db-up` then `db:deploy`), `migrate` (`prisma migrate dev`), `seed`, `admin` (`admin:create`, interactive), `cleanup` (`data:cleanup`), plus one target per import script (`import`, `shop-images`…). `package.json` scripts: `setup:env`, `db:generate`, `db:migrate`, `db:deploy`, `db:seed`, `admin:create`, `data:*`. Scripts that import `server/*` run as `node --conditions=react-server --import tsx …` or `server-only` throws. A first run is `make setup && make db-setup && make seed && make admin && make dev`.

## Makefile
Every project has one, so `make dev` starts any of them. `help` is the default goal and lists the targets in one `printf`; one target per `package.json` script, `check` runs the four CI checks in order, and a project adds a target for each of its own build scripts (`make fox-dots`, `make frames SRC=…`). Projects with a database add the targets under "Local database" above.
```make
.DEFAULT_GOAL := help
.PHONY: help install setup dev build start lint typecheck test check

# Prefer the installed Homebrew Node on this Mac; other systems fall back to PATH.
export PATH := /opt/homebrew/bin:$(PATH)
PNPM ?= pnpm

help:
	@printf '%s\n' 'make setup      Install dependencies' 'make dev        Start the website' 'make check      Lint, type-check, test and build, as CI does' 'make build / start / lint / typecheck / test    Explicit commands only'

install:
	$(PNPM) install --frozen-lockfile --ignore-scripts

setup: install

dev:
	$(PNPM) run dev

build:
	$(PNPM) run build

start:
	$(PNPM) run start

lint:
	$(PNPM) run lint

typecheck:
	$(PNPM) run typecheck

test:
	$(PNPM) test

check: lint typecheck test build
```
`package.json` has the matching scripts: `dev`, `build`, `start`, `lint` (`eslint .`), `typecheck` (`tsc --noEmit`), `test`, `format`.
