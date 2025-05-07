AUTHOR = 'Kubecoin'
SITENAME = 'kubecoin.io'
SITEURL = "https://kubecoin.io" # Use https for production

SUBTITLE = 'Kubecoin'
SUBTEXT = 'Kubernetes-powered Crypto Platform'

PATH = "content"
PAGE_PATHS = ['pages']
ARTICLE_PATHS = ['posts']
THEME = 'themes/papyrus'
THEME_STATIC_PATHS = ['static']
PLUGIN_PATHS = ['pelican-plugins']
PLUGINS = ['pelican-toc', 'search'] # Replace 'tipue_search' with 'search'
STATIC_PATHS = ['images', 'extra', 'admin/index.html', 'admin/config.yml']
DISPLAY_PAGES_ON_MENU = True
DISPLAY_CATEGORIES_ON_MENU = False

# Add this setting for pelican-search to know what content to index
SEARCH_HTML_SELECTOR = "main" 
STORK_CONFIG = {
    'SEARCH_USE_CDN': False,
    # Add any other Stork-specific configurations here if needed
}

# --- Add/Modify this section for Favicons ---
EXTRA_PATH_METADATA = {
    # Map the favicon from its source location to the output root
    'images/uploads/favicon.ico': {'path': 'favicon.ico'},
    # Optional: Map other common icons if you have them
    # 'images/uploads/apple-touch-icon.png': {'path': 'apple-touch-icon.png'},
    # 'images/uploads/favicon-32x32.png': {'path': 'favicon-32x32.png'},
    # 'images/uploads/favicon-16x16.png': {'path': 'favicon-16x16.png'},
    # 'images/uploads/site.webmanifest': {'path': 'site.webmanifest'}, # If using a manifest
}
# --- End Favicon Section ---

# Custom templates directory to override theme templates
THEME_TEMPLATES_OVERRIDES = ['templates']

# Required for the Papyrus theme
DIRECT_TEMPLATES = ['index', 'tags', 'categories', 'authors', 'archives', 'search']

TIMEZONE = 'UTC'

DEFAULT_LANG = 'EN'

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# Blogroll
LINKS = (
    ("Pelican", "https://getpelican.com/"),
    ("Python.org", "https://www.python.org/"),
    ("Jinja2", "https://palletsprojects.com/p/jinja/"),
    # ("You can modify those links in your config file", "#"),
    ('Admin', '/admin/'), # Use relative path for admin link
)

# Social widget - Update these
SOCIAL = (
    ("github", "https://github.com/KubeCoin-io"),
    ("discord", "#"), # Placeholder for Discord link
    # ("twitter", "https://twitter.com/your-profile"),
)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True

# Exclude admin directory from being processed as content
PAGE_EXCLUDES = ['admin']
ARTICLE_EXCLUDES = ['admin']