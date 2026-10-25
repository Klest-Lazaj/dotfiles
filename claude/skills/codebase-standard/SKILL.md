---
name: codebase-standard
description: The house standard for Next.js + Tailwind + TypeScript projects: the stack, one folder per component (index/styles/types/static/functions), a single globals.css, tw() class lists, design tokens, the @shadcn/lint rules and the checks. Use when writing, moving or reviewing code in a web project, and when starting one.
---

# Codebase standard

## Stack
- Next.js (App Router, latest), React 19, TypeScript `strict`, `@/*` → project root.
- Tailwind CSS v4 via `@tailwindcss/postcss`. There is no tailwind.config: tokens live in `app/globals.css`.
- Icons come from `lucide-react` only, imported by their `…Icon` names (`ArrowUpRightIcon`). Give each one `size` and `strokeWidth`, and `aria-hidden="true"` when it is decorative. No hand-written SVG icons, no second icon set.
- pnpm, Prettier (2 spaces), ESLint 9 flat config: `eslint-config-next/core-web-vitals` + `@shadcn/lint`.
- zod at every trust boundary: one schema, shared by the form and the route that receives it.
- Only when the project needs them: GSAP (+ Lenis) for motion, Resend + React Email for mail.
- No new dependency for what a few lines can do.

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
- Tests are plain Node scripts: `scripts/check-*.mjs` using `node:assert/strict`, run by `pnpm test`. No test framework.
- Nothing is done until `pnpm lint`, `pnpm exec tsc --noEmit`, `pnpm test` and `pnpm build` pass. GitHub Actions runs the same four on pull requests and pushes to main, after `pnpm install --frozen-lockfile`.
- A new project starts by copying in `lib/tw.ts`, the lint config above, `.vscode/settings.json`, `.prettierrc` (`tabWidth: 2`), the CI workflow, and a `globals.css` laid out as above.
