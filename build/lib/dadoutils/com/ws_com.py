import asyncio
from threading import Thread

import websockets


class WsCom(Thread):

    @staticmethod
    async def echo(websocket):
        async for message in websocket:
            print(message)
            await websocket.send(message)

    @staticmethod
    async def main():
        async with websockets.serve(WsCom.echo, "localhost", 8765):
            await asyncio.Future()  # run forever

    @staticmethod
    async def await_send(msg):
        async with websockets.connect("ws://localhost:8765") as websocket:
            await websocket.send(msg)
            await websocket.recv()

    def send(self, msg):
        asyncio.run(self.send(msg))
        #thread = Thread(target=WsCom.await_send, args=msg)
        #thread.start()

    def run(self):
        asyncio.run(self.main())