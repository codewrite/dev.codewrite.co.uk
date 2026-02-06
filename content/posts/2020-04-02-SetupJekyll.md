---
title: "Setting Up Jekyll"
date: 2020-04-02
draft: false
categories:
  - jekyll
---

The first thing I did was [installed Ubuntu on windows][Ubuntu Install]

Then I [installed NodeJS and NPM][Install NodeJS] (which I'm not sure if I needed).

And then [installed Jekyll][Install Jekyll]

To run it: `jekyll serve --host=0.0.0.0`

I edited .bashrc to add the GEM exports

```bash
# Ruby exports
export GEM_HOME=$HOME/gems
export PATH=$HOME/gems/bin:$PATH
```


I added a couple of files to the _includes folder:

*head.html*
```html
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    {%- seo -%}
    <link rel="stylesheet" href="{{ "/assets/main.css" | relative_url }}">
    <link rel="stylesheet" href="{{ "/assets/css/main.css" | relative_url }}">
    {%- feed_meta -%}
    {%- if jekyll.environment == 'production' and site.google_analytics -%}
      {%- include google-analytics.html -%}
    {%- endif -%}
</head>
```

in the file above I added a link to my css file - which is built from main.scss in the assets/css folder.

and the in *header.html* I added _if my_page.hidden != true_ so I could have posts thant wouldn't get listed:

```html
    <div class="trigger">
    {%- for path in page_paths -%}
        {%- assign my_page = site.pages | where: "path", path | first -%}
        {%- if my_page.title -%}
        {%- if my_page.hidden != true -%}
            <a class="page-link" href="{{ my_page.url | relative_url }}">{{ my_page.title | escape }}</a>
        {%- endif -%}
        {%- endif -%}
    {%- endfor -%}
    </div>
```

I did a similar thing for *home.html* in the _layouts folder:

```html
    <ul class="post-list">
      {%- assign date_format = site.minima.date_format | default: "%b %-d, %Y" -%}
      {%- for post in posts -%}
        {%- if post.hidden != true -%}
          <li>
            <span class="post-meta">{{ post.date | date: date_format }}</span>
            <h3>
              <a class="post-link" href="{{ post.url | relative_url }}">
                {{ post.title | escape }}
              </a>
            </h3>
            {%- if site.show_excerpts -%}
              {{ post.excerpt }}
            {%- endif -%}
          </li>
        {%- endif -%}
      {%- endfor -%}
    </ul>
```

All these files came from the Github repo at the end of this article.

<hr/>

This is the base Jekyll theme. You can find out more info about customizing your Jekyll theme, as well as basic Jekyll usage documentation at [jekyllrb.com](https://jekyllrb.com/)

You can find the source code for Minima at GitHub:
[jekyll][jekyll-organization] /
[minima](https://github.com/jekyll/minima)

You can find the source code for Jekyll at GitHub:
[jekyll][jekyll-organization] /
[jekyll](https://github.com/jekyll/jekyll)

[jekyll-organization]: https://github.com/jekyll

[Ubuntu Install]: https://docs.microsoft.com/en-us/windows/wsl/install-win10
[Install Jekyll]: https://computingforgeeks.com/how-to-install-jekyll-on-ubuntu-18-04/
[Install NodeJS]: https://github.com/nodesource/distributions/blob/master/README.md

