import datetime

AUTHOR = 'Kubecoin'
SITENAME = 'kubecoin.io'
SITEURL = "https://kubecoin.io" # Use https for production
SITELOGO = 'images/uploads/favicon-96x96.png' # Use favicon-96x96.png for the logo

SUBTITLE = 'Kubecoin'
SUBTEXT = 'Kubernetes-powered Crypto Platform'

PATH = "content"
PAGE_PATHS = ['pages']
ARTICLE_PATHS = ['posts']
THEME = 'themes/papyrus'
THEME_STATIC_PATHS = ['static']
PLUGIN_PATHS = ['pelican-plugins']
PLUGINS = [
    'pelican-toc',
    'tailwindcss',
    'linkclass',
    'mau_reader',
    'jinja2content',
    'jinja_filters',
    'pandoc_reader',
    'injector',
    'liquid_tags',
    'read_more',
    'more_categories',
    'thumbnailer',
    'yaml_metadata',
    'simple_footnotes',
    'webring',
    'feed_filter'
]
STATIC_PATHS = ['images', 'extra', 'admin'] # Added 'admin'
DISPLAY_PAGES_ON_MENU = True
DISPLAY_CATEGORIES_ON_MENU = False

COPYRIGHT = f'© {SITENAME} {datetime.date.today().year}'

# --- Add/Modify this section for Favicons ---
EXTRA_PATH_METADATA = {
    'extra/_headers': {'path': '_headers'}, # Updated path for _headers
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
DIRECT_TEMPLATES = ['index', 'tags', 'categories', 'authors', 'archives']

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

# Markdown Extension Configuration
MARKDOWN = {
    'extension_configs': {
        'markdown.extensions.codehilite': {'css_class': 'highlight'},
        'markdown.extensions.extra': {},
        'markdown.extensions.meta': {},
        'markdown_include.include': {'base_path': 'content'}, # Add markdown_include here
    },
    'output_format': 'html5',
}

# Tailwind CSS Plugin Configuration
TAILWIND_INPUT_FILE = 'themes/papyrus/tailwind.css' # Path relative to project root
TAILWIND_CONFIG_FILE = 'themes/papyrus/tailwind.config.js' # Path relative to project root
TAILWIND_OUTPUT_FILE = 'css/main.css'
TAILWIND_MINIFY = False  # Set to False for development (pelicanconf.py)
TAILWIND_NODE_ENV = 'development' # Set to 'development' for development
# When running `pelican -r`, set to True to rebuild Tailwind on changes
# TAILWIND_WATCH = True # Consider for local development with `pelican -r`

# Pelican TOC Plugin Configuration
TOC_HEADERS = r"h[2-6]"  # Include headers h2 through h6
TOC_RUN = 'true'  # Enable ToC generation per article (can be overridden in article metadata)

# Linkclass Plugin Configuration
LINKCLASS_CSS_CLASS = 'external-link' # Default is 'external'
# LINKCLASS_EXTERNAL_SITES = [SITEURL] # Add your site to treat subdomains as internal if needed

# Read More Plugin Configuration
READ_MORE_LINK = '<a class="text-primary hover:underline" href="/{url}#more">Read more »</a>'
READ_MORE_SEPARATOR = '<!-- more -->' # Default separator

# Thumbnailer Plugin Configuration (Adjust paths and sizes as needed)
# THUMBNAILER_DEFAULT_SIZE = '192x192'  # e.g., '100x100', '200xauto'
# THUMBNAILER_SOURCE_PATH = 'images/uploads' # Relative to PATH (content folder)
# THUMBNAILER_OUTPUT_PATH = 'images/thumbnails' # Relative to OUTPUT_PATH
# THUMBNAILER_SQUARE = False # Set to True for square thumbnails

# Webring Plugin Configuration (Provide your webring feed URL)
# WEBRING_FEED_URL = 'YOUR_WEBRING_FEED_URL_HERE'
# WEBRING_MY_SITE_URLS = [SITEURL] # Your site's URL(s) in the webring

# Feed Filter Plugin Configuration (Example: exclude 'drafts' category from feeds)
# FEED_FILTER_EXCLUDE_CATEGORIES = ['drafts']
# FEED_FILTER_EXCLUDE_TAGS = []
# FEED_FILTER_INCLUDE_CATEGORIES = []
# FEED_FILTER_INCLUDE_TAGS = []

# Injector Plugin Configuration (Example: add a custom script to head)
# INJECTOR_ITEMS = [
#     ("<!-- Custom Analytics -->", "head_end", "base.html"),
# ]