# pelicanconf.py

# Basic settings
AUTHOR = 'Kubecoin Team'
SITENAME = 'Kubecoin'
SITEURL = ''

# Paths
PATH = 'content'
PAGE_PATHS = ['pages']
ARTICLE_PATHS = ['posts']
STATIC_PATHS = ['images', 'extra', 'admin']

# Theme and plugins
THEME = 'themes/papyrus'
THEME_STATIC_PATHS = ['static']
PLUGIN_PATHS = ['pelican-plugins']
PLUGINS = ['readtime', 'search', 'neighbors', 'pelican-toc']

# Timezone and language
TIMEZONE = 'UTC'
DEFAULT_LANG = 'en'

# Development settings
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None
AUTHOR_FEED_ATOM = None
AUTHOR_FEED_RSS = None

# URL settings
ARTICLE_URL = 'posts/{slug}/'
ARTICLE_SAVE_AS = 'posts/{slug}/index.html'
PAGE_URL = '{slug}/'
PAGE_SAVE_AS = '{slug}/index.html'