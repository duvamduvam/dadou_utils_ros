import asyncio
import logging
import traceback

from dadou_utils.com.serial_devices_manager import SerialDeviceManager
from dadou_utils.misc import Misc
from dadou_utils.utils_static import LORA, ANGLO, KEY, JOY


class Message:

    event_loop = asyncio.new_event_loop()

    def __init__(self, ws_clients, device_manager: SerialDeviceManager):
        self.ws_clients = ws_clients
        self.lora = device_manager.get_device(LORA)

    def send(self, msg: dict):
        if self.lora and self.lora.exist():
            self.send_lora(msg)
        else:
            self.send_multi_ws(msg)

    def send_multi_ws(self, msg: dict):
        for ws_client in self.ws_clients:
            ws_client.send(msg)

    @staticmethod
    async def send_ws(msg, ws_client):
        try:
            logging.info("send {} to {}".format(msg, ws_client.name))
            ws_client.send(msg)
        except Exception as e:
            logging.error("{} can't send msg {}".format(ws_client.name, e))
            traceback.print_exc()

    def send_lora(self, msg:dict):
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
