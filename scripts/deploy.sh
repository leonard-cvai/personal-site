#!/usr/bin/env bash
# Uploads dist/ to S3 and invalidates CloudFront. Used by CI; also runnable locally after `npm run build`.
set -euo pipefail

BUCKET="${S3_BUCKET:-leonardgrazian-com-site}"
DISTRIBUTION_ID="${CLOUDFRONT_DISTRIBUTION_ID:-E8W11B5B1J3AX}"

# Fingerprinted assets never change, so browsers can cache them forever.
aws s3 sync dist/_astro "s3://$BUCKET/_astro" \
  --cache-control "public, max-age=31536000, immutable"

# Everything else (HTML, PDF, favicon) must pick up new deploys quickly.
aws s3 sync dist "s3://$BUCKET" --delete --exclude "_astro/*" \
  --cache-control "public, max-age=0, must-revalidate"

# Remove stale fingerprinted assets last, so pages being served never lose them mid-deploy.
aws s3 sync dist/_astro "s3://$BUCKET/_astro" --delete \
  --cache-control "public, max-age=31536000, immutable"

aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*" \
  --query 'Invalidation.Id' --output text
