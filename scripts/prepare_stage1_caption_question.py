import json
import argparse
import os


def process_file(input_filename, output_filename):
    with open(input_filename, "r") as file:
        lines = file.readlines()

    jsonlist = []

    for line in lines:
        json_data = json.loads(line)
        json_data["text"] = "describe the scene in the image in one sentence."
        jsonlist.append(json_data)

    os.makedirs(os.path.dirname(output_filename), exist_ok=True)

    with open(output_filename, "w") as file:
        for item in jsonlist:
            json.dump(item, file)
            file.write("\n")


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-filename", type=str)
    parser.add_argument("--output-filename", type=str)
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()
    process_file(args.input_filename, args.output_filename)
