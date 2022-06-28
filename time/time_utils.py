import time



class TimeUtils:

    @staticmethod
    def formatted_time(time_stamp):
        mlsec = repr(time_stamp).split('.')[1][:2]
        return time.strftime("%M:%S:{}".format(mlsec), time.localtime(time_stamp))
