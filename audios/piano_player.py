import os

from playsound import playsound

from dadou_utils_ros.utils_static import JSON_NOTES, NOTE, DEFAULT, JSON_DIRECTORY, JSON_CONFIG, AUDIOS_DIRECTORY
from robot.files.robot_json_manager import RobotJsonManager
from robot.robot_config import config

MODE = DEFAULT


class PianoPlayer:

    def __init__(self, robot_json_manager: RobotJsonManager):
        self.datas = robot_json_manager.get_json_file(config[JSON_NOTES])
        self.notes = self.datas["jazz"]

    def process(self, msg):
        if msg and NOTE in msg:
            playsound(config[AUDIOS_DIRECTORY]+"notes/"+self.notes[msg[NOTE]])