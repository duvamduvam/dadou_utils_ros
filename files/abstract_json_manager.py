import json
import logging
import re
import os

import jsonpath_rw_ext


class AbstractJsonManager:
    # '{}_{}_{}_{}'.format(s1, i, s2, f)

    NAME = 'name'
    PATH = 'path'

    def __init__(self, base_folder, json_folder, config_name):

        self.base_folder = base_folder
        self.json_folder = base_folder+json_folder
        self.config = self.open_json(config_name)

        #with open(config_file, 'r') as json_file:
        #    self.config = json.load(json_file)

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

    @staticmethod
    def get_dict_from_list(dicts, key, value):
        for d in dicts:
            for k, v in d.items():
                if k == key and value in v:
                    return d

    @staticmethod
    def get_attribut(json_object, key):
        if key in json_object:
            return json_object[key]
        else:
            logging.error('key {} not found'.format(key))
            return None

    def open_json(self, file_name, mode='r'):
        #if folder:
        #    path = self.json_folder + folder + file_name
        #else :
        path = self.json_folder + file_name
        with open(path, mode) as json_file:
            return json.load(json_file)

    def get_config(self) -> {}:
        return self.config

    def get_config_item(self, name):
        item = self.config[name]
        if item:
            return item
        else:
            logging.error("no item config {}".format(item))

    def delete_item(self, items, name):
        for item in items:
            if item['name'] == name:
                items.remove(item)
                return
        logging.error('name {} not found in items {}'.format(name, items))

    def save_file(self, datas, name, folder=""):
        with open(self.json_folder+folder+name, 'w') as outfile:
            json.dump(datas, outfile, indent=4)


