import json
import argparse
import os


def process_file(input_filename, output_filename, dataset_name, format_filename):
    data = []
    with open(input_filename, "r") as file:
        data = json.load(file)

    jsondatalist = []
    for i in range(len(data)):
        if data[i]["dataset_name"] == dataset_name:
            if isinstance(data[i]["answers"], list):
                dataanswers = data[i]["answers"]
            else:
                dataanswers = [data[i]["answers"]]
            jsondata = {
                "question": data[i]["question"],
                "image_id": str(data[i]["id"]),
                "image_classes": data[i]["dataset_name"],
                "answers": dataanswers,
                "question_id": str(data[i]["id"]),
                "set_name": "val",
            }
            jsondatalist.append(jsondata)

    with open(format_filename, "r") as file:
        vqa_data = json.load(file)

    vqa_data["data"] = jsondatalist

    os.makedirs(os.path.dirname(output_filename), exist_ok=True)

    with open(output_filename, "w") as file:
        json.dump(vqa_data, file)


def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--input-filename", type=str)
    parser.add_argument("--output-filename", type=str)
    parser.add_argument("--dataset-name", type=str)
    parser.add_argument("--format-filename", type=str)
    return parser.parse_args()


if __name__ == "__main__":
    args = get_args()
    process_file(
        args.input_filename,
        args.output_filename,
        args.dataset_name,
        args.format_filename,
    )
