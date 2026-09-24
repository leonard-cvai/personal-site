# CLAUDE.md

Personal blog and portfolio for Leonard Grazian, live at https://leonardgrazian.com.
Fully static: Astro builds HTML, which is served from a private S3 bucket through CloudFront.
There is no server, database, or API, and nothing should add one.

## Stack

- **Astro 7** (static output), **Tailwind CSS v4** via `@tailwindcss/vite`, `@tailwindcss/typography` for post bodies
- **Styling** ported from [ekmas/neobrutalism-components](https://github.com/ekmas/neobrutalism-components).
  Their React components were copied as plain `.astro` components. Don't add React or other UI frameworks.
- **PDF.js** (`pdfjs-dist` v6) renders the resume on `/resume/`. It is the only client-side JS besides analytics.
- **Plausible** analytics (site-specific `pa-…` script in `src/layouts/Base.astro`, production builds only)
- **Terraform** in `infra/` for all AWS resources; **GitHub Actions** deploys on push to `main`

## Layout

```
src/
  content.config.ts        blog collection schema (title, description, date, draft)
  content/blog/*.md        posts; filename = URL slug (/blog/<slug>/)
  layouts/Base.astro       <head>, meta tags, Plausible, header, <main> wrapper
  components/              Button, Card, Badge (ported), Header (name + Home/Resume/Contact)
  pages/                   index (post list, newest first), resume, contact, 404, blog/[...slug]
  styles/global.css        theme tokens (colors, shadow, radius, font) + grid background
  lib/format.ts            date formatting (UTC)
public/                    served as-is: resume PDF, favicon
scripts/deploy.sh          S3 sync + CloudFront invalidation (used by CI and locally)
infra/                     Terraform: bucket, CloudFront, ACM cert, Route 53, rewrite function, GitHub OIDC role
.github/workflows/deploy.yml
```

## Commands

```sh
npm install
npm run dev        # http://localhost:4321
npm run build      # outputs dist/; must pass before any commit
npx astro preview  # serve dist/ locally (Plausible loads here but ignores localhost)
```

There are no tests. Verify changes by building and looking at the pages in a browser
at desktop (~1280px) and phone (375px) widths. Check for horizontal overflow and console errors.

## Common tasks

**Add a blog post:** create `src/content/blog/<slug>.md` with frontmatter:

```md
---
title: "Post title"
description: "One-line summary shown on the home page card."
date: 2026-09-24
draft: false   # optional; true hides it from the list and doesn't build the page
---
```

**Update the resume:** replace `public/leonard_grazian_resume.pdf`, keeping the filename,
since `resume.astro` links to it.

**Change theme colors:** edit the CSS variables in `:root` in `src/styles/global.css`
(`--main` is the accent, `--background` the card fill). Keep the variable names; the
ported components depend on them.

**Add a page:** create `src/pages/<name>.astro` wrapped in `<Base title=… description=…>`.
To add it to the nav, update the `links` array in `src/components/Header.astro`.

## Conventions

- Reuse `Button`, `Card`, `Badge` rather than hand-rolling borders and shadows. If you need a new
  neobrutalist component, port its Tailwind classes from the upstream repo's
  `src/components/ui/*.tsx` into an `.astro` component, keeping the same variant names.
- The neobrutalist look = 2px black borders, `shadow-shadow` offset shadows, `rounded-base`,
  and buttons that press on hover (`hover:translate-x-boxShadowX hover:translate-y-boxShadowY hover:shadow-none`).
- Internal links use absolute paths with trailing slashes (`/resume/`, `/blog/slug/`).
- Keep pages lightweight: no new client-side JS unless a feature truly needs it, and scope it to that page.
- Match the existing code style: TypeScript in frontmatter, double quotes, 2-space indent.

## Deployment

- Push to `main` → the workflow runs `npm ci && npm run build`, assumes the IAM role
  `personal-site-github-deploy` via OIDC (no stored AWS keys), then runs `scripts/deploy.sh`.
- `deploy.sh` uploads `_astro/*` (fingerprinted) with a one-year immutable cache, uploads everything
  else with `max-age=0`, then invalidates `/*`. Changes are live within about a minute.
- Manual deploy (needs local AWS credentials for account 747587436362):
  `npm run build && AWS_REGION=us-east-1 scripts/deploy.sh`

## Infrastructure (`infra/`)

- All resources are in **us-east-1** (CloudFront requires its ACM certificate there).
  The local AWS CLI default region may be different, so pass `--region us-east-1` / `AWS_REGION`.
- State lives in `s3://leonardgrazian-terraform-state` (key `personal-site/terraform.tfstate`).
- Site bucket `leonardgrazian-com-site` is private; only the CloudFront distribution
  (`E8W11B5B1J3AX`) can read it, via Origin Access Control.
- `infra/rewrite.js` is a CloudFront Function (cloudfront-js-2.0, ES5-ish syntax) that
  301-redirects `www.` to the apex, keeping the query string, and maps `/path` and `/path/` to
  `/path/index.html`. Keep query strings intact: `?ref=` links are used to track outreach.
- Always run `terraform plan` and show the diff to the user before `terraform apply`.
- The older bucket named `leonardgrazian.com` (2018 logs) is unrelated and unmanaged. Don't touch it.

## Gotchas

- `pdfjs-dist` v6: `getDocument` requires an object (`getDocument({ url })`), not a bare string.
- PDF.js's worker is imported with `?url` and must be served as `text/javascript` (the S3 sync does this).
- Headless browsers have no built-in PDF plugin, which is why the resume uses PDF.js rather than `<object>`.
- Tailwind scans `.astro` files, including strings inside `<script>`, so classes set from JS still work.
- Plausible's tracked events (file downloads, outbound links) are toggled in the Plausible
  dashboard, not in code.

## Don'ts

- Don't commit secrets, `.env*`, Terraform state, or `infra/.terraform/`.
- Don't make the S3 bucket public or switch to S3 static-website hosting. CloudFront + OAC is intentional.
- Don't add server-side features, cookies, or extra trackers without asking the owner
  (these would require a consent banner).
