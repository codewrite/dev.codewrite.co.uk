# Codewrite Dev Blog - Hugo Version

This is the new Hugo-based version of the Codewrite dev blog, migrated from Jekyll.

## Building

To build the site:

```bash
hugo
```

## Running Locally

To run the development server:

```bash
hugo server -D
```

The site will be available at `http://localhost:1313`

## Directory Structure

- `content/` - All content (posts and pages)
  - `posts/` - Blog posts
  - `about/` - About page
  - `general/` - General pages
  - `RPI-dotnet/` - Raspberry Pi .NET articles
- `static/` - Static files (images, sounds, CSS)
  - `images/` - Images used in content
  - `sounds/` - Audio files
  - `css/` - Stylesheets
- `themes/` - Hugo themes (Minima theme)

## Configuration

Main configuration is in `hugo.toml`

## Content Structure

All blog posts are in `content/posts/` and should include frontmatter with:
- `title` - Post title
- `date` - Publication date (YYYY-MM-DD)
- `draft` - Whether the post is a draft
- `categories` - Comma-separated categories

## Hugo Modules

This site uses the Minima theme, a minimal and responsive theme for Hugo.
