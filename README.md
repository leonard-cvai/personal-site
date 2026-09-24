# leonardgrazian.com

Static blog built with [Astro](https://astro.build), styled after
[neobrutalism-components](https://github.com/ekmas/neobrutalism-components),
hosted on S3 + CloudFront, analytics by [Plausible](https://plausible.io).

## Writing posts

Add a Markdown file to `src/content/blog/`:

```md
---
title: "Post title"
description: "One-line summary shown on the home page."
date: 2026-09-24
draft: false # optional; true hides the post
---
```

The filename becomes the URL (`my-post.md` → `/blog/my-post/`).
To update the resume, replace `public/leonard_grazian_resume.pdf`.

## Local development

```sh
npm install
npm run dev      # http://localhost:4321
```

## Deploying

Pushing to `main` builds and deploys via `.github/workflows/deploy.yml`
(GitHub OIDC → IAM role `personal-site-github-deploy`; no stored keys).
To deploy by hand with local AWS credentials: `npm run build && scripts/deploy.sh`.

## Infrastructure

Terraform in `infra/` (state in `s3://leonardgrazian-terraform-state`):
private S3 bucket, CloudFront with an ACM certificate, Route 53 records for
the apex and `www` (which redirects to the apex), and the GitHub deploy role.

```sh
cd infra && terraform init && terraform plan
```
