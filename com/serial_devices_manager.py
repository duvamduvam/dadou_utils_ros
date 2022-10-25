import logging

from os.path import exists
from dadou_utils.com.serial_device import SerialDevice
from dadou_utils.time.time_utils import TimeUtils
from dadou_utils.utils_static import NAME, TYPE, SERIAL_ID, DEVICE_MSG_SIZE


class SerialDeviceManager:
    last_update = 0
    update_period = 500

    def __init__(self, expected_devices):

        self.expected_devices = expected_devices
        self.existing_devices = []

        self.update_devices()
        #schedule.every(10).seconds.do(self.update_devices)

    def update_devices(self):
        self.update_period = TimeUtils.current_milli_time()
        for expected_device in self.expected_devices:
            expected_device_exist = exists(SerialDevice.USB_ID_PATH+expected_device[SERIAL_ID])
            new_device = True
            for existing_device in self.existing_devices:
                if expected_device[NAME] == existing_device.name:
                    if not expected_device_exist:
                        self.remove_device(existing_device.name)
                    new_device = False
                    break
            if new_device and expected_device_exist:
                self.add_device(SerialDevice(expected_device[NAME], expected_device[SERIAL_ID],
                                             expected_device[TYPE], expected_device[DEVICE_MSG_SIZE]))

    def add_device(self, device):
        self.existing_devices.append(device)
        logging.info("add device {}".format(device.name))

    def remove_device(self, name):
        device = self.get_device(name)
        self.existing_devices.remove(device)
        logging.warning("device {} removed".format(name))

    def get_device(self, name):
        for device in self.existing_devices:
            if device.name == name:
                return device

    def get_device_type(self, type):
        devices = []
        for device in self.existing_devices:
            if device.type == type:
                devices.append(device)
        return devices