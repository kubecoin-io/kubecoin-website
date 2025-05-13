# This file is only used if you use `make publish` or
# explicitly specify it as your config file.

import os
import sys

sys.path.append(os.curdir)
from pelicanconf import *

# If your site is available via HTTPS, make sure SITEURL begins with https://
SITEURL = "https://kubecoin.io/"
RELATIVE_URLS = False

FEED_ALL_ATOM = "feeds/all.atom.xml"
CATEGORY_FEED_ATOM = "feeds/{slug}.atom.xml"

DELETE_OUTPUT_DIRECTORY = True

# Configure pagination for archives to fix the 'dates_page' variable undefined error
PAGINATED_TEMPLATES = {'archives': None, 'period_archives': None}
PAGINATION_PATTERNS = (
    (1, '{url}', '{save_as}'),
    (2, '{base_name}/page/{number}/', '{base_name}/page/{number}/index.html'),
)

STATIC_PATHS = ['images', 'extra', 'admin'] # Added 'admin'
EXTRA_PATH_METADATA = {
    # Removed for Pagefind
    # ...
}

# Following items are often useful when publishing

# DISQUS_SITENAME = ""
# GOOGLE_ANALYTICS = ""

# Tailwind CSS Plugin Configuration (Production)
TAILWIND_INPUT_FILE = 'themes/papyrus/tailwind.css'
TAILWIND_CONFIG_FILE = 'themes/papyrus/tailwind.config.js'
TAILWIND_OUTPUT_FILE = 'css/main.css' # Output to themes/papyrus/static/css/main.css
TAILWIND_MINIFY = True
TAILWIND_NODE_ENV = 'production'
