#!/bin/bash
# Update GitHub Pages site

# Render the site
quarto render

# Add changes
git add docs

# Commit with timestamp
git commit -m "update $(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Push changes
git push

echo "updated"


git add docs
git commit -m "update"
git push
echo "updated"