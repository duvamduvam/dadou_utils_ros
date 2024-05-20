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

    @staticmethod
    def clean_string(string, char_list):
        for char in char_list:
            string = string.replace(char, '')
        return string.lstrip()

    @staticmethod
    def lstring_list_clean(input_list):
        output_list = []
        for input in input_list:
            output_list.append(input.lstrip())
        return output_list

#    @staticmethod
#    def get_path(file, base_path):
#        for child in listdir(base_path):

#    @staticmethod
#    def search_file_in_folder(file, folder):


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