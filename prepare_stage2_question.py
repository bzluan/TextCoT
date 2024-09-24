import json
import argparse
import os

def process_files(stage1_input_filename, original_vqa_filename, output_filename):
    # 读取Stage1输入文件
    with open(stage1_input_filename, 'r') as file:
        lines = file.readlines()

    # 读取原始vqa文件
    with open(original_vqa_filename, 'r') as file:
        original_vqa_lines = file.readlines()

    jsonlist = []
    # 限制处理行数为文件行数的最小值，避免越界
    min_lines = min(len(lines), len(original_vqa_lines), 5000)
    for i in range(min_lines):
        line = lines[i]
        original_vqa_line = original_vqa_lines[i]
        original_line = json.loads(original_vqa_line)
        
        inputline = json.loads(line)
        stage1text = inputline['text'] + '\n'
        context = 'Use the image and text information as context and answer the following question: \n'
        question = inputline['prompt'].split("\n")[0] + '\n'
        stage2_prompt = '\nAnswer the question using a single word or phrase.'
        
        outputtext = stage1text + context + question + stage2_prompt
        
        outputline = {
            "question_id": inputline["question_id"],
            "image": original_line['image'],
            "text": outputtext
        }
        
        jsonlist.append(outputline)

    # Ensure the output directory exists
    os.makedirs(os.path.dirname(output_filename), exist_ok=True)
    
    # 写入输出文件
    with open(output_filename, 'w') as file:
        for item in jsonlist:
            json.dump(item, file)
            file.write('\n')

def get_args():
    parser = argparse.ArgumentParser(description="Generate Stage 2 data from Stage 1 output and original vqa files.")
    parser.add_argument('--stage1-input-filename', type=str, help='Stage 1 input JSONL file path')
    parser.add_argument('--original-vqa-filename', type=str, help='Original vqa JSONL file path')
    parser.add_argument('--output-filename', type=str, help='Output JSONL file path for Stage 2')
    return parser.parse_args()

if __name__ == "__main__":
    args = get_args()
    process_files(args.stage1_input_filename, args.original_vqa_filename, args.output_filename)
