import logging


class Message:

    def __int__(self, msg):
        self.msg = msg
        if msg is not dict:
            logging.warning("input {} is not a dictionary".format(msg))

    def get(self, key):
            if not self.msg[key]:
                logging.warning("no => {} <= in message".format(key))
            return self.msg[key]

    def key(self):
        return self.get('key')