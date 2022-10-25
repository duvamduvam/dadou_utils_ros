import asyncio
import logging
from threading import Thread
import uvloop

import websockets
from dadou_utils.com.input_messages_list import InputMessagesList


class WsServer(Thread):

    @staticmethod
    async def handler(websocket):
        async for message in websocket:
            InputMessagesList().messages.append(message)
            logging.info(message)
            print(message)
            await websocket.send("from ws : "+message)

    @staticmethod
    async def main():
        async with websockets.serve(WsServer.handler, "0.0.0.0", 4421):
            await asyncio.Future()  # run forever

    def run(self):
        uvloop.install()
        asyncio.run(WsServer.main())

