import json
import argparse
import os

def process_sroie_data(input_filename, output_filename, dataset_name):
    data = []
    with open(input_filename, 'r') as file:
        data = json.load(file)

    jsonlist = []
    for i in range(len(data)):
        outputline = {
            "question_id": "id",
            "image": "image.jpg",
            "text": "",
            "category": "default"
        }
        if data[i]['dataset_name'] == dataset_name:
            outputline["question_id"] = str(data[i]['id'])
            outputline["image"] = data[i]['image_path']
            outputline["text"] = data[i]['question'] + '\nAnswer the question using a single word or phrase.'
            jsonlist.append(outputline)

    os.makedirs(os.path.dirname(output_filename), exist_ok=True)

    with open(output_filename, 'w') as file:
        for item in jsonlist:
            json.dump(item, file)
            file.write('\n')

def get_args():
    parser = argparse.ArgumentParser(description="Convert dataset to JSON Lines format.")
    parser.add_argument('--input-filename', type=str)
    parser.add_argument('--output-filename', type=str)
    parser.add_argument('--dataset-name', type=str)
    return parser.parse_args()

if __name__ == "__main__":
    args = get_args()
    process_sroie_data(args.input_filename, args.output_filename, args.dataset_name)
