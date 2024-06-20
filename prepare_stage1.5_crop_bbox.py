import json
import re
from PIL import Image
import argparse
import os


def get_args():
    parser = argparse.ArgumentParser(description="Process images based on bounding box adjustments.")
    parser.add_argument('--input-jsonl', type=str, help='Input JSON Lines file path with image data and bounding boxes.')
    parser.add_argument('--original-images-jsonl', type=str, help='Original STVQA JSONL file path.')
    parser.add_argument('--output-dir', type=str, help='Directory path for saving cropped images.')
    return parser.parse_args()

def adjust_bbox_expand(bbox_ratios, width, height, expand_ratio=1.5, min_size=448):
    x_min = bbox_ratios[0] * width
    y_min = bbox_ratios[1] * height
    x_max = bbox_ratios[2] * width
    y_max = bbox_ratios[3] * height
    bbox = [x_min,y_min,x_max,y_max]
    
    center_x = (x_min + x_max) / 2
    center_y = (y_min + y_max) / 2

    size = max(x_max - x_min, y_max - y_min) * expand_ratio

    size = max(size, min_size)
    
    if size> width or size > height:
        return [0,0,1,1]

    new_x_min = center_x - size / 2
    new_y_min = center_y - size / 2
    new_x_max = center_x + size / 2
    new_y_max = center_y + size / 2

    if new_x_min < 0:
        new_x_max = new_x_max - new_x_min
        new_x_min = 0
    if new_y_min < 0:
        new_y_max = new_y_max - new_y_min
        new_y_min = 0
    if new_x_max > width - 1:
        new_x_min =  new_x_min - new_x_max + width - 1
        new_x_max = width - 1
    if new_y_max > height - 1:
        new_y_min = new_y_min - new_y_max + height - 1
        new_y_max = height - 1
        
    return [new_x_min/width, new_y_min/height, new_x_max/width, new_y_max/height]



def process_images(input_jsonl, original_images_jsonl, output_dir):
    with open(input_jsonl, 'r') as file:
        lines = file.readlines()
    with open(original_images_jsonl, 'r') as file:
        original_stvqa_lines = file.readlines()
    
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    for i in range(min(5000, len(lines), len(original_stvqa_lines))):
        inputline = json.loads(lines[i])
        original_line = json.loads(original_stvqa_lines[i])
        
        image_path = os.path.join('playground/data/eval/data', original_line['image'])
        image = Image.open(image_path)
        width, height = image.size

        data = inputline['text']
        pattern = r'\[\-?\d+\.\d+, \-?\d+\.\d+, \-?\d+\.\d+, \-?\d+\.\d+\]'
        matches = re.findall(pattern, data)
        
        bbox_ratios = [0, 0, 1, 1] if len(matches) == 0 else [float(j) for j in matches[0].strip('[]').split(',')]
        
        if 0 <= bbox_ratios[0] < bbox_ratios[2] <= 1 and 0 <= bbox_ratios[1] < bbox_ratios[3] <= 1:
            adjust_bbox_ratios = adjust_bbox_expand(bbox_ratios, width, height)
            adjust_bbox = (
                width * adjust_bbox_ratios[0],  # x0
                height * adjust_bbox_ratios[1], # y0
                width * adjust_bbox_ratios[2],  # x1
                height * adjust_bbox_ratios[3]  # y1
            )
            cropped_image = image.crop(adjust_bbox)
        else:
            cropped_image = image

        cropped_image = cropped_image.convert("RGB")
        
        os.makedirs(os.path.dirname(output_dir), exist_ok=True)
        
        save_path = os.path.join(output_dir, f'{original_line["question_id"]}_{original_line["image"].split("/")[-1]}')
        cropped_image.save(save_path)

if __name__ == "__main__":
    args = get_args()
    process_images(args.input_jsonl, args.original_images_jsonl, args.output_dir)
