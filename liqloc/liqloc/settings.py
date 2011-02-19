# Scrapy settings for liqloc project
#
# For simplicity, this file contains only the most important settings by
# default. All the other settings are documented here:
#
#     http://doc.scrapy.org/topics/settings.html
#

BOT_NAME = 'liqloc'
BOT_VERSION = '1.0'

SPIDER_MODULES = ['liqloc.spiders']
NEWSPIDER_MODULE = 'liqloc.spiders'
DEFAULT_ITEM_CLASS = 'liqloc.items.Spirit'

ITEM_PIPELINES = [
    'liqloc.pipelines.DuplicatesPipeline',
    'liqloc.pipelines.SpiritCleanerPipeline',
    'liqloc.pipelines.GeoCodeStorePipeline',
    'liqloc.pipelines.ValidateItemPipeline',
    'liqloc.pipelines.SaveItemPipeline',
    'liqloc.pipelines.ToggleTablesPipeline',
    'liqloc.pipelines.EmailStatsPipeline'
]

USER_AGENT = '%s/%s' % (BOT_NAME, BOT_VERSION)

MAIL_HOST = 'localhost'
MAIL_FROM = 'rob@larubbio.org'

LOG_FILE = 'output.log'
LOG_STDOUT = True

ROBOTSTXT_OBEY = True
STATSMAILER_RCPTS = ['rob@larubbio.org']
