from os import listdir, path
from os.path import isfile, join

from PIL import Image

class FilesUtils:


    #def __init__(self, config: ControlConfig):
    #    self.config = config

    @staticmethod
    def get_folder_files(folder):
        files = []
        for file in listdir(folder):
            full_path = join(folder, file)
            if path.isfile(full_path):
                files.append(full_path)
        return files

    @staticmethod
    def get_folder_files_name(folder):
        return [f for f in listdir(folder) if isfile(join(folder, f))]

    """def get_image(self, type, name):
        if type == self.EYE:
            return Image.open(self.config.base_path + self.EYE_VISUALS_PATH + name)
        if type == self.MOUTH:
            return Image.open(self.config.base_path + self.MOUTH_VISUALS_PATH + name)
        return None

    def get_folder_path(self, type):
        if type == self.EYE:
            return config.

    def get_folder_files_name(self, folder):
        return [f for f in listdir(folder) if isfile(join(folder, f))]
    """