# Quick Reference - Hugo Site at dev.codewrite.co.uk

## Location
`c:\dev\html\dev.codewrite.co.uk\`

## Common Commands

### Development
```powershell
cd c:\dev\html\dev.codewrite.co.uk
hugo server -D          # Run local server (http://localhost:1313)
```

### Production Build
```powershell
cd c:\dev\html\dev.codewrite.co.uk
hugo                    # Build to public/ directory
```

### Clean Build
```powershell
Remove-Item public -Recurse -Force
hugo
```

## Important Files

- `hugo.toml` - Site configuration
- `content/posts/` - Blog posts
- `content/*/` - Other pages
- `static/images/` - Images
- `themes/minima/` - Theme templates
- `public/` - Generated site

## Add New Content

### New Blog Post
```bash
# Create file: content/posts/YYYY-MM-DD-slug.md
---
title: "Post Title"
date: 2024-01-15
draft: false
categories:
  - category1
---

Content here...
```

### New Page
```bash
# Create in content/ with proper structure
# Use _index.md for section pages
```

## Site Statistics
- 11 blog posts
- 6 pages
- 28 images
- 33 generated HTML pages

## Key Configuration

| Setting | Value |
|---------|-------|
| Base URL | https://dev.codewrite.co.uk/ |
| Language | en-us |
| Theme | minima |
| Output Formats | HTML, RSS |
| Unsafe HTML | Enabled |

## Hugo Files Structure

```
dev.codewrite.co.uk/
├── content/           # Markdown content
├── static/            # Images, CSS, etc.
├── themes/minima/     # Theme (custom conversion)
├── public/            # Generated site
├── hugo.toml          # Configuration
└── README.md          # Documentation
```

## Common Tasks

**View site locally:**
```bash
hugo server -D
```

**Check build:**
```bash
hugo
```

**Add post:**
Create `content/posts/YYYY-MM-DD-title.md` with frontmatter

**Deploy:**
Copy contents of `public/` to web server

## Migration Notes

- Converted from Jekyll
- All content migrated successfully
- All images updated to new paths
- Liquid template tags converted
- Raw HTML rendering enabled for content compatibility

## Reference
- Full documentation: See `DEPLOYMENT.md`
- Migration report: See `MIGRATION_REPORT.md`
- Theme details: See `themes/minima/README.md`
