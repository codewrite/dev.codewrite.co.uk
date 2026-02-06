# Hugo Site Deployment Guide

## Site Information

- **Source:** Converted from Jekyll at `dev-old.codewrite.co.uk`
- **Destination:** `dev.codewrite.co.uk`
- **Generator:** Hugo v0.155.2+
- **Theme:** Minima (custom Hugo theme conversion)

## Build and Deployment

### Local Development

To run the development server:

```bash
hugo server -D
```

This will start a local server at `http://localhost:1313` with draft content enabled.

### Production Build (Local)

To build the site for GitHub Pages deployment:

```bash
hugo --minify
```

The generated static site will be in the `docs/` directory.

### GitHub Pages Deployment

#### Automatic Deployment (Recommended)

This site is configured for automatic deployment to GitHub Pages via GitHub Actions using GitHub's native Pages environment:

1. Push changes to the `main` branch
2. GitHub Actions automatically builds and deploys the site
3. Site is published to `https://dev.codewrite.co.uk`

**Setup Requirements:**
1. Go to repository Settings → Pages
2. Under "Build and deployment":
   - Source: **GitHub Actions**
3. Ensure custom domain is configured to point to `dev.codewrite.co.uk`

The workflow will:
- Build the Hugo site with minification
- Upload artifacts to GitHub Pages
- Deploy automatically using GitHub's Pages deployment API

**Trigger Deployment:**
- Push to `main` branch (automatic)
- Or manually trigger from Actions tab

#### Manual Deployment (Local)

To manually build and deploy:

```bash
# Build the site
./deploy.sh

# Commit and push
git add docs/
git commit -m "Deploy site [skip ci]"
git push origin main
```

### Configuration

- **Base URL:** `https://dev.codewrite.co.uk/`
- **Output Directory:** `docs/` (for GitHub Pages)
- **Theme:** Minima (custom Hugo conversion)
- **Hugo Version:** 0.155.2+ (extended recommended)

### Directory Structure

```
dev.codewrite.co.uk/
├── content/              # All content files
│   ├── _index.md        # Home page
│   ├── posts/           # Blog posts
│   ├── about/           # About page
│   ├── general/         # General pages
│   └── RPI-dotnet/      # Raspberry Pi .NET articles
├── static/              # Static assets
│   ├── images/          # Images (copied from Jekyll)
│   ├── sounds/          # Audio files
│   └── css/             # Stylesheets
├── themes/minima/       # Minima theme (Hugo conversion)
│   └── layouts/         # Theme templates
├── public/              # Generated site (build output)
├── hugo.toml            # Hugo configuration
└── README.md            # This file
```

## Migration Details

### What Was Converted

- **Posts:** 11 blog posts from Jekyll `_posts/` directories
- **Pages:** 6 pages from Jekyll `pages/` directories
- **Assets:** All images (28 files) and sounds
- **Frontmatter:** Jekyll YAML frontmatter converted to Hugo format
- **Layouts:** Jekyll theme layouts converted to Hugo templates
- **Configuration:** Jekyll `_config.yml` converted to Hugo `hugo.toml`

### Key Changes from Jekyll

1. **Post Format:** Posts use standard Hugo format in `content/posts/`
2. **Image Paths:** Changed from `/assets/images/` to `/images/`
3. **Template Syntax:** Converted from Liquid to Go templates
4. **Highlights:** Converted Jekyll `{% highlight %}` to markdown code fences
5. **Raw HTML:** Hugo configuration allows unsafe HTML rendering for content compatibility

### Post Frontmatter Format

```yaml
---
title: "Post Title"
date: 2020-08-13
draft: false
categories:
  - category1
  - category2
---
```

## Configuration

Main configuration file: `hugo.toml`

Key settings:
- `baseURL` - Site URL
- `languageCode` - Language setting
- `title` - Site title
- `theme` - Theme name (minima)
- `params` - Custom parameters (description, email, social links)
- `markup.goldmark.renderer.unsafe = true` - Allow raw HTML in content

## Adding New Content

### New Blog Post

Create a file in `content/posts/` with the naming pattern `YYYY-MM-DD-slug.md`:

```markdown
---
title: "My New Post"
date: 2024-01-15
draft: false
categories:
  - category1
---

Your content here...
```

### New Page

Create a file in `content/` with appropriate directory structure and include `_index.md` for section pages.

## RSS and Feeds

- Main feed: `/index.xml`
- Posts feed: `/posts/index.xml`
- Category feeds: `/categories/{category}/index.xml`

## Hosting

The `public/` directory contains the complete static site ready for deployment to any web server.

### Common Deployment Options

1. **Web Server (IIS, Nginx, Apache):** Copy contents of `public/` to web root
2. **GitHub Pages:** Push `public/` directory to `gh-pages` branch
3. **Netlify:** Connect repository and set build command to `hugo`
4. **Vercel:** Similar to Netlify, set build command to `hugo`

## Notes

- The site uses raw HTML rendering for compatibility with Jekyll content
- All Jekyll Liquid tags have been converted to Hugo equivalents
- Images and sounds are served from the static directory
- The Minima theme is a custom conversion from the Jekyll theme
