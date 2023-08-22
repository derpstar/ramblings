#/usr/bin/python

import yaml
import sys

def find_section(data, section):
    """Recursively search for a section in a dictionary."""
    if section in data:
        return data[section]
    
    for key, value in data.items():
        if isinstance(value, dict):
            found = find_section(value, section)
            if found:
                return found
    return None

def get_flattened_values(section_data):
    """Retrieve and flatten values from the found section."""
    return ' '.join(map(str, section_data.values()))

def main():
    if len(sys.argv) < 3:
        print("Usage: python script_name.py path_to_yaml_file host_section")
        return
    
    filepath = sys.argv[1]
    section = sys.argv[2]
    
    with open(filepath, 'r') as file:
        data = yaml.safe_load(file)

    section_data = find_section(data, section)
    if section_data:
        print(get_flattened_values(section_data))
    else:
        print(f"{section} not found in {filepath}")

if __name__ == '__main__':
    main()
