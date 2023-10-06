from dadou_utils.singleton import SingletonMeta


class InputMessagesList(metaclass=SingletonMeta):

    def __init__(self):
        self.messages = []

    def add_msg(self, msg):
        self.messages.append(msg)

    def has_msg(self):
        return len(self.messages) != 0

    def pop_msg(self):
        msg = {}
        if len(self.messages) > 0:
            msg = self.messages[0]
            self.messages.pop()
        return msg

    def get_all(self):
        dictionary = {}
        for msg in self.messages:
            dictionary.update(msg)
        self.messages = []
        return dictionary
