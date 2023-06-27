import asyncio
import logging
import traceback
from threading import Thread

from dadou_utils.utils_static import ANGLO, KEY, JOY


class Message:

    event_loop = asyncio.new_event_loop()

    def __init__(self, ws_clients, device_manager=None):
        self.ws_clients = ws_clients
        #self.lora = device_manager.get_device(LORA)
        self.lora = None

    def send(self, msg: dict):
        #if self.lora and self.lora.exist():
        #    self.send_lora(msg)
        #else:
        self.send_multi_ws(msg)

    def send_multi_ws(self, msg: dict):

        for ws_client in self.ws_clients:
            #args=(msg,) parenthesis nedeed otherwise only the key is passed
            thread = Thread(target=ws_client.send, args=(msg,))
            thread.start()

    def send_lora(self, msg: dict):
        if ANGLO in msg:
            self.lora.send_msg('A'+msg[ANGLO])
        if KEY in msg:
            self.lora.send_msg('K'+msg[KEY])
        if JOY in msg:
            self.lora.send_msg('J'+msg[JOY])

    """def __int__(self, msg):
        self.msg = msg
        if msg is not dict:
            logging.warning("input {} is not a dictionary".format(msg))

    def get(self, key):
            if not self.msg[key]:
                logging.warning("no => {} <= in message".format(key))
            return self.msg[key]

    def key(self):
        return self.get('key')"""
