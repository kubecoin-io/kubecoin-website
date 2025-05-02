AUTHOR = 'Kubecoin'
SITENAME = 'kubecoin.io'
SITEURL = "http://kubecoin.io"

SUBTITLE = 'Kubecoin'
SUBTEXT = 'Kubernetes-powered Crypto Platform'

PATH = "content"
PAGE_PATHS = ['pages']
ARTICLE_PATHS = ['posts']
THEME = 'themes/papyrus'
THEME_STATIC_PATHS = ['static']
PLUGIN_PATHS = ['pelican-plugins']
PLUGINS = ['pelican-toc']  # Remove 'readtime', 'search', 'neighbors' as they might not be installed
STATIC_PATHS = ['images', 'extra', 'admin/index.html', 'admin/config.yml']
DISPLAY_PAGES_ON_MENU = True
DISPLAY_CATEGORIES_ON_MENU = False

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
    ("You can modify those links in your config file", "#"),
)

# Social widget
SOCIAL = (
    ("You can add links in your config file", "#"),
    ("Another social link", "#"),
)

DEFAULT_PAGINATION = 10

# Uncomment following line if you want document-relative URLs when developing
# RELATIVE_URLS = True
