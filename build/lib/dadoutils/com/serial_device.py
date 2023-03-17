from builtins import staticmethod
from os.path import exists

from serial import SerialException

import serial
import logging
import sys

class SerialDevice:
    TERMINATOR = '\n'.encode('UTF8')
    USB_ID_PATH = "/dev/serial/by-id/"
    plugged = False

    def __init__(self, serialId):
        self.serialPath = serialId

    def connect(self):
        try:
            device_exists = exists(self.serialPath)
            if(device_exists):
                self.device = serial.Serial(self.serialPath, 115200, timeout=1)
                logging.info('serial connected  : ' + self.serialPath)
                self.plugged = True
        except SerialException:
            logging.error("serial id "+self.serialPath+"not present\n", sys.exc_info()[0])
            pass

    def get_msg(self):
        if self.plugged and self.device.isOpen() and exists(self.serialPath):
            # logging.info("{} connected!".format(self.arduino.port))
            if self.device.inWaiting() > 0:
                line = self.device.read_until(self.TERMINATOR)
                msg = line.decode('UTF8').strip()
                logging.info('received from arduino : ' + msg)
                return msg
        return None

    def send_msg(self, msg):
        if self.device.isOpen():
            self.device.write(msg)

    def setPlugedIn(self, connected):
        self.plugged = connected
