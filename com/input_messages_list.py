import json

from dadou_utils.singleton import SingletonMeta


class InputMessagesList(metaclass=SingletonMeta):

    def __init__(self):
        self.messages = []

    def add_msg(self, msg):
        self.messages.append(msg)

    def pop_msg(self):
        msg = None
        if len(self.messages) > 0:
            msg = json.loads(self.messages[0])
            self.messages.pop()
        return msg