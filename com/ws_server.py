import asyncio
import logging
from threading import Thread
import uvloop

import websockets

from dadou_utils.singleton import SingletonMeta


class WsServer(Thread):

    async def handler(websocket):
        async for message in websocket:
            WsMessage().messages.append(message)
            logging.info(message)
            print(message)
            await websocket.send("I recieved : "+message)

    @staticmethod
    async def main():
        async with websockets.serve(WsServer.handler, "0.0.0.0", 4421):
            await asyncio.Future()  # run forever

    def run(self):
        uvloop.install()
        asyncio.run(WsServer.main())


class WsMessage(metaclass=SingletonMeta):

    def __init__(self):
        self.messages = []

    def add_msg(self, msg):
        self.messages.append(msg)

    def get_msg(self):
        msg = None
        if len(self.messages) > 0:
            msg = self.messages[0]
            self.messages.pop()
        return msg
