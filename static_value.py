from dadou_utils.singleton import SingletonMeta


class StaticValue(metaclass=SingletonMeta):
    value = None

    @staticmethod
    def get():
        v = StaticValue.value
        StaticValue.value= None
        return v
