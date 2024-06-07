class LoggingConf:
    @staticmethod
    def get(file_name, process_name):
        return {
            'version': 1,
            'loggers': {
                '': {  # root logger
                    'level': 'NOTSET',
                    'handlers': ['debug_console_handler', 'info_rotating_file_handler'],
                },
                'websockets': {
                    'level': 'WARNING',
                    'propagate': False,
                    'handlers': ['debug_console_handler', 'info_rotating_file_handler'],
                },
            },
            'handlers': {
                'debug_console_handler': {
                    'level': 'INFO',
                    'formatter': 'info',
                    'class': 'logging.StreamHandler',
                    'stream': 'ext://sys.stdout',
                },
                'info_rotating_file_handler': {
                    'level': 'INFO',
                    'formatter': 'info',
                    'class': 'logging.handlers.TimedRotatingFileHandler',
                    'filename': file_name,
                    'when': 'midnight',
                    'interval': 2,
                    'backupCount': 100
                }
            },
            'formatters': {
                'info': {
                    'class': 'colorlog.ColoredFormatter',
                    'format': '%(asctime)s {} %(funcName)s |%(lineno)s: %(levelname)s%(log_color)s %(message)s%(reset)s'.format(
                        process_name)
                }
            },
        }

    @staticmethod
    def get_test():
        return {
            'version': 1,
            'loggers': {
                '': {  # root logger
                    'level': 'NOTSET',
                    'handlers': ['debug_console_handler'],
                },
            },
            'handlers': {
                'debug_console_handler': {
                    'level': 'INFO',
                    'formatter': 'info',
                    'class': 'logging.StreamHandler',
                    'stream': 'ext://sys.stdout',
                }
            },
            'formatters': {
                'info': {
                    'class': 'colorlog.ColoredFormatter',
                    'format': '%(asctime)s %(pathname)s %(funcName)s |%(lineno)s: %(log_color)s%(message)s%(reset)s'
                }
            },
        }