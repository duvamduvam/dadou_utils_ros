
import json
import logging
import re
import os

import jsonpath_rw_ext
from dadou_utils.utils_static import KEYS, JSON_DIRECTORY, BASE_PATH, NAME


class AbstractJsonManager:
    # '{}_{}_{}_{}'.format(s1, i, s2, f)

    def __init__(self, config, json_keys):
        self.config = config
        self.json_files = {}
        for json_key in json_keys:
            self.json_files[json_key] = self.open_json(json_key)

    def get_json_file(self, name):
        return self.json_files["JSON_"+name]

    @staticmethod
    def standard_return(result, return_first, attribut):
        # logging.debug(result)
        to_return = {}
        error = False

        if not bool(result):
            error = True
        else:
            if return_first:
                if len(result) > 0:
                    to_return = result[0]
                else:
                    error = True
            else:
                to_return = result
            if attribut:
                to_return = to_return[attribut]

        if not error:
            return to_return

        return None

    @staticmethod
    def find(json_data, iterate_key, expression):
        result = 0
        for seq in json_data[iterate_key]:
            if len(jsonpath_rw_ext.match(expression, seq)) > 0:
                result = seq
        return result

    def get_dict_from_list(self, json_file, key, value):
        data = self.json_files[json_file]
        for d in data:
            for k, v in d.items():
                if k == key and value in v:
                    return d

    def get_dict_with_key(self, type, key):
        return self.get_dict_from_list(type, KEYS, key)

    @staticmethod
    def get_attribut(json_object, key):
        if key in json_object:
            return json_object[key]
        else:
            logging.error('key {} not found'.format(key))
            return None

    def get_attributs_list(self, json_file, key):
        attributs_list = []
        for file in self.json_files[json_file]:
            attributs_list.append(file[key])
        return attributs_list

    def get_keys_list(self, json_file):
        return self.json_files[json_file].keys()

    def get_element_from_key(self, json_file, key, value):
        self.json_files[json_file]
        for result in self.json_files[json_file]:
            if result[key] == value:
                return result

    def open_json(self, file_name, directory=""):
        path = self.config[BASE_PATH] + self.config[JSON_DIRECTORY] + directory + file_name
        with open(path, 'r') as json_file:
            return json.load(json_file)

    def delete_item(self, items, name):
        for item in items:
            if item[NAME] == name:
                items.remove(item)
                return
        logging.error('name {} not found in items {}'.format(name, items))

    def save_file(self, datas, name, folder=""):
        with open(self.config[BASE_PATH] +self.config[JSON_DIRECTORY]+folder+name, 'w') as outfile:
            json.dump(datas, outfile, indent=4)
        self.json_files[name] = self.open_json(folder+name)

