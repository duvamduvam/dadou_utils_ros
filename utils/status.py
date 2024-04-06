import asyncio
import logging
import os
import re
import subprocess
import time

import psutil
from digitalio import DigitalInOut, Direction, Pull

from dadou_utils_ros.misc import Misc
from dadou_utils_ros.utils.time_utils import TimeUtils

SHUTDOWN_CMD = 'sudo shutdown now -h'
RESTART_CMD = 'sudo reboot'
STATUS_LED_INTERVAL = 500
SYSTEM_STATUS_PERIOD = 500000
MAX_CPU = 80
MAX_MEMORY = 80
MAX_DISK = 80
MAX_CPU_TEMP = 55


class Status:
    def __init__(self, shutdown_pin, status_pin, restart_pin=None, battery_pin=None,
                 battery_led_indicator_pins=None, battery_min=None, battery_max=None):

        self.shutdown_button = DigitalInOut(shutdown_pin)
        self.shutdown_button.direction = Direction.INPUT
        self.shutdown_button.pull = Pull.UP

        if battery_pin:
            self.battery = AnalogIn(battery_pin)
            self.battery_min, self.battery_max = battery_min, battery_max
            self.battery_leds = [self.init_battery_leds(battery_led_indicator_pins)]

        self.restart_pin = restart_pin
        if restart_pin:
            self.restart_button = DigitalInOut(restart_pin)
            self.restart_button.direction = Direction.INPUT
            self.restart_button.pull = Pull.UP

        self.status_led = DigitalInOut(status_pin)
        self.status_led.direction = Direction.OUTPUT

        self.last_status_check_time, self.last_led_status_check = (0, 0)

    def init_battery_leds(self, battery_led_indicator_pins):
        leds = []
        for led_pin in battery_led_indicator_pins:
            led = DigitalInOut(led_pin)
            led.direction = Direction.OUTPUT
            leds.append(led)
        return leds

    def update(self, msg):
        return msg

    def process(self):
        self.check_button(self.shutdown_button, SHUTDOWN_CMD)
        if self.restart_pin:
            self.check_button(self.restart_button, RESTART_CMD)
        self.led_status()

        if TimeUtils.is_time(self.last_status_check_time, SYSTEM_STATUS_PERIOD):
            asyncio.run(Status.status_functions())
            self.check_battery()
            self.last_status_check_time = TimeUtils.current_milli_time()

    @staticmethod
    async def status_functions():
        Status.check_cpu()
        Status.check_memory()
        Status.check_disk()
        Status.check_cpu_temp()

    def check_battery(self):
        if not hasattr(self, 'battery'):
            return

        battery_value = (self.battery.value * 3.3) / 65536
        battery_percentage = Misc.percentage(battery_value, self.battery_min, self.battery_max)

        for i in range(len(self.battery_leds)):
            self.battery_leds[i].value = battery_percentage >= (i+1)*(100/len(self.battery_leds))


    @staticmethod
    def check_cpu():
        cpu = psutil.cpu_percent()
        if cpu >= MAX_CPU:
            logging.warning("high cpu load {}%".format(cpu))

    @staticmethod
    def check_memory():
        memory = psutil.virtual_memory()
        if memory.percent > MAX_MEMORY:
            # Convert Bytes to MB (Bytes -> KB -> MB)
            available = round(memory.available / 1024.0 / 1024.0, 1)
            total = round(memory.total / 1024.0 / 1024.0, 1)
            logging.warning("high memory load {} MB free {} MB total => {}%".format(available, total, memory.percent))

    @staticmethod
    def check_disk():
        # Calculate disk information
        disk = psutil.disk_usage('/')
        if disk.percent > MAX_DISK:
            # Convert Bytes to GB (Bytes -> KB -> MB -> GB)
            free = round(disk.free / 1024.0 / 1024.0 / 1024.0, 1)
            total = round(disk.total / 1024.0 / 1024.0 / 1024.0, 1)
            logging.warning("high disk usage {} GB Free {} GB total => {}%".format(free, total, disk.percent))

    @staticmethod
    def check_cpu_temp():
        err, msg = subprocess.getstatusoutput('vcgencmd measure_temp')
        if not err:
            m = re.search(r'-?\d\.?\d*', msg)  # a solution with a  regex
            try:
                temp = float(m.group())
                if temp >= MAX_CPU_TEMP:
                    logging.warning("high cpu temp {}".format(temp))
            except ValueError:  # catch only error needed
                pass

    def check_button(self, button, command):
        #logging.debug("{} {}".format(button, button.value))
        if not button.value:
            # Check to see if button is pressed
            time.sleep(1)
            # wait for the hold time
            if not button.value:
                # check to see if button is pressed
                logging.warning("exec command_root {}".format(command))
                os.system(command)
                time.sleep(1)

    def led_status(self):
        if TimeUtils.is_time(self.last_led_status_check, STATUS_LED_INTERVAL):
            self.status_led.value = not self.status_led.value
            self.last_led_status_check = TimeUtils.current_milli_time()

