import json
import argparse

def get_args():
    parser = argparse.ArgumentParser()
    parser.add_argument('--stage1-input-jsonl', type=str, help='Path to the Stage 1 output JSONL file.')
    parser.add_argument('--stage1-caption-input-jsonl', type=str, help='Path to the Stage 1 caption output JSONL file.')
    parser.add_argument('--original-vqa-jsonl', type=str, help='Path to the original VQA JSONL file.')
    parser.add_argument('--output-jsonl', type=str)
    return parser.parse_args()

def process_stage2_data(stage1_input_jsonl, stage1_caption_input_jsonl, original_vqa_jsonl, output_jsonl):
    with open(stage1_input_jsonl, 'r') as file:
        lines = file.readlines()
    with open(stage1_caption_input_jsonl, 'r') as file:
        captionlines = file.readlines()
    with open(original_vqa_jsonl, 'r') as file:
        original_vqa_lines = file.readlines()

    jsonlist = []
    for i in range(min(5000, len(lines), len(original_vqa_lines))):
        line = lines[i]
        captionline = captionlines[i]
        original_vqa_line = original_vqa_lines[i]
        original_line = json.loads(original_vqa_line)
        caption_line = json.loads(captionline)
        
        outputline = {
            "question_id": "default_id", 
            "image": "default_image.jpg", 
            "text": "Default question text", 
            "category": "default"
        }

        inputline = json.loads(line)
        
        stage1_caption = "This is a cropped image from: " + caption_line['text'] + '\n'
        context = 'Use the image and text information as context and answer the following question: \n'
        question = inputline['prompt'].split("\n")[0] + '\n'
        stage2_prompt = 'Answer the question using a single word or phrase.'

        outputtext = stage1_caption + context + question + stage2_prompt

        outputline["question_id"] = inputline["question_id"]
        outputline["image"] = str(original_line["question_id"]) + '_' + original_line['image'].split('/')[-1]
        outputline["text"] = outputtext

        jsonlist.append(outputline)

    with open(output_jsonl, 'w') as file:
        for item in jsonlist:
            json.dump(item, file)
            file.write('\n')

if __name__ == "__main__":
    args = get_args()
    process_stage2_data(args.stage1_input_jsonl, args.stage1_caption_input_jsonl, args.original_vqa_jsonl, args.output_jsonl)