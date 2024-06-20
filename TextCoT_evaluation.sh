IMAGE_FOLDER=playground/data/eval/data
CKPT=${1-'llava-v1.5-7b'}

DATASETS=("textVQA" "STVQA" "docVQA" "infographicVQA" "ChartQA" "POIE" "SROIE" "FUNSD" )

for DATASETNAME in "${DATASETS[@]}"; do
    echo "Processing Dataset: $DATASETNAME"

    echo "########################################################################################################################"
    echo ${DATASETNAME}

    ########################################################################################################################
    # prepare baseline answer and question file
    echo "#####   prepare baseline answer and question file"

    python lbz_scripts/generate_answer_file.py \
    --input-filename playground/data/eval/FullTest.json \
    --output-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_answer.json \
    --dataset-name ${DATASETNAME} \
    --format-filename playground/data/eval/answer_format.json

    python lbz_scripts/generate_baseline_question_file.py \
    --input-filename playground/data/eval/FullTest.json \
    --output-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl \
    --dataset-name ${DATASETNAME}

    ########################################################################################################################
    # run baseline:
    echo "#####   run baseline:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}

    echo ${CKPT}


   for IDX in $(seq 0 $((CHUNKS-1))); do
    CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
        --model-path liuhaotian/${CKPT} \
        --question-file playground/data/eval/${DATASETNAME_LOWER}/${DATASETNAME_LOWER}_baseline_input.jsonl \
        --image-folder ${IMAGE_FOLDER} \
        --answers-file ./playground/data/eval/${DATASETNAME_LOWER}/answers_baseline/${CKPT}/${CHUNKS}_${IDX}.jsonl \
        --num-chunks $CHUNKS \
        --chunk-idx $IDX \
        --temperature 0 \
        --conv-mode vicuna_v1 &
    done

    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_baseline/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_baseline/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done

    python -m llava.eval.eval_stvqa \
        --annotation-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_answer.json \
        --result-file ./playground/data/eval/${DATASETNAME}/answers_baseline/${CKPT}/merge.jsonl

    # ########################################################################################################################
    # prepare stage1 caption input:
    echo "#####   prepare stage1 caption input:"

    python lbz_scripts/prepare_stage1_caption_question.py \
    --input-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl   \
    --output-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage1_caption_input.jsonl

    ########################################################################################################################
    # run stage1 caption:
    echo "#####   run stage1 caption:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}

    echo ${CKPT}

    for IDX in $(seq 0 $((CHUNKS-1))); do
        CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
            --model-path liuhaotian/${CKPT} \
            --question-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage1_caption_input.jsonl \
            --image-folder ${IMAGE_FOLDER} \
            --answers-file ./playground/data/eval/${DATASETNAME}/answers_stage1_caption/${CKPT}/${CHUNKS}_${IDX}.jsonl \
            --num-chunks $CHUNKS \
            --chunk-idx $IDX \
            --temperature 0 \
            --conv-mode vicuna_v1 &
    done

    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_stage1_caption/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_stage1_caption/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done


    ########################################################################################################################
    # prepare stage1 input:
    echo "#####   prepare stage1 input:"

    python lbz_scripts/prepare_stage1_question.py \
    --input-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl   \
    --output-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage1_input.jsonl


    ########################################################################################################################
    # run stage1:
    echo "#####   run stage1:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}

    echo ${CKPT}

    for IDX in $(seq 0 $((CHUNKS-1))); do
        CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
            --model-path liuhaotian/${CKPT} \
            --question-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage1_input.jsonl \
            --image-folder ${IMAGE_FOLDER} \
            --answers-file ./playground/data/eval/${DATASETNAME}/answers_stage1/${CKPT}/${CHUNKS}_${IDX}.jsonl \
            --num-chunks $CHUNKS \
            --chunk-idx $IDX \
            --temperature 0 \
            --conv-mode vicuna_v1 &
    done
    
    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_stage1/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_stage1/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done

    ########################################################################################################################
    # prepare stage2 input:
    echo "#####   prepare stage2 input:"

    python lbz_scripts/prepare_stage2_question.py \
    --stage1-input-filename playground/data/eval/${DATASETNAME}/answers_stage1/${CKPT}/merge.jsonl  \
    --original-vqa-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl \
    --output-filename playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_input.jsonl

    ########################################################################################################################
    # run stage2:
    echo "#####   run stage2:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}



    echo ${CKPT}

    for IDX in $(seq 0 $((CHUNKS-1))); do
        CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
            --model-path liuhaotian/${CKPT} \
            --question-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_input.jsonl \
            --image-folder ${IMAGE_FOLDER} \
            --answers-file ./playground/data/eval/${DATASETNAME}/answers_stage2/${CKPT}/${CHUNKS}_${IDX}.jsonl \
            --num-chunks $CHUNKS \
            --chunk-idx $IDX \
            --temperature 0 \
            --conv-mode vicuna_v1 &
    done
    
    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_stage2/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_stage2/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done

    python -m llava.eval.eval_stvqa \
        --annotation-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_answer.json \
        --result-file playground/data/eval/${DATASETNAME}/answers_stage2/$CKPT/merge.jsonl

    ########################################################################################################################
    # prepare stage2 crop input:
    echo "#####   prepare stage2 crop input:"

    python lbz_scripts/prepare_stage1.5_crop_bbox.py \
    --input-jsonl playground/data/eval/${DATASETNAME}/answers_stage1/${CKPT}/merge.jsonl \
    --original-images-jsonl playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl \
    --output-dir playground/data/eval/${DATASETNAME}/test_images_cropped

    python lbz_scripts/prepare_stage2_crop_question.py \
    --stage1-input-jsonl playground/data/eval/${DATASETNAME}/answers_stage1/${CKPT}/merge.jsonl \
    --original-vqa-jsonl playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl \
    --output-jsonl playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_crop_input.jsonl

    ########################################################################################################################
    # run stage2 crop:
    echo "#####   run stage2 crop:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}

    echo ${CKPT}

    for IDX in $(seq 0 $((CHUNKS-1))); do
        CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
            --model-path liuhaotian/${CKPT} \
            --question-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_crop_input.jsonl \
            --image-folder playground/data/eval/${DATASETNAME}/test_images_cropped \
            --answers-file ./playground/data/eval/${DATASETNAME}/answers_stage2_crop/${CKPT}/${CHUNKS}_${IDX}.jsonl \
            --num-chunks $CHUNKS \
            --chunk-idx $IDX \
            --temperature 0 \
            --conv-mode vicuna_v1 &
    done
    
    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_stage2_crop/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_stage2_crop/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done

    python -m llava.eval.eval_stvqa \
        --annotation-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_answer.json \
        --result-file playground/data/eval/${DATASETNAME}/answers_stage2_crop/$CKPT/merge.jsonl

    ########################################################################################################################
    # prepare stage2 crop_with_caption input:
    echo "#####   prepare stage2 crop_with_caption input:"

    python lbz_scripts/prepare_stage2_crop_with_caption_question.py \
    --stage1-input-jsonl playground/data/eval/${DATASETNAME}/answers_stage1/${CKPT}/merge.jsonl \
    --stage1-caption-input-jsonl playground/data/eval/${DATASETNAME}/answers_stage1_caption/${CKPT}/merge.jsonl \
    --original-vqa-jsonl playground/data/eval/${DATASETNAME}/${DATASETNAME}_baseline_input.jsonl \
    --output-jsonl playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_crop_with_caption_input.jsonl

    ########################################################################################################################
    # run stage2 crop_with_caption:
    echo "#####   run stage2 crop_with_caption:"

    gpu_list="${CUDA_VISIBLE_DEVICES=0,1,2,3}"
    IFS=',' read -ra GPULIST <<< "$gpu_list"

    CHUNKS=${#GPULIST[@]}

    echo ${CKPT}

    for IDX in $(seq 0 $((CHUNKS-1))); do
        CUDA_VISIBLE_DEVICES=${GPULIST[$IDX]} python -m llava.eval.model_vqa_loader \
            --model-path liuhaotian/${CKPT} \
            --question-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_stage2_crop_with_caption_input.jsonl \
            --image-folder playground/data/eval/${DATASETNAME}/test_images_cropped \
            --answers-file ./playground/data/eval/${DATASETNAME}/answers_stage2_crop_with_caption/${CKPT}/${CHUNKS}_${IDX}.jsonl \
            --num-chunks $CHUNKS \
            --chunk-idx $IDX \
            --temperature 0 \
            --conv-mode vicuna_v1 &
    done

    wait

    output_file=./playground/data/eval/${DATASETNAME}/answers_stage2_crop_with_caption/$CKPT/merge.jsonl

    # Clear out the output file if it exists.
    > "$output_file"

    # Loop through the indices and concatenate each file.
    for IDX in $(seq 0 $((CHUNKS-1))); do
        cat ./playground/data/eval/${DATASETNAME}/answers_stage2_crop_with_caption/$CKPT/${CHUNKS}_${IDX}.jsonl >> "$output_file"
    done

    python -m llava.eval.eval_stvqa \
        --annotation-file playground/data/eval/${DATASETNAME}/${DATASETNAME}_answer.json \
        --result-file playground/data/eval/${DATASETNAME}/answers_stage2_crop_with_caption/$CKPT/merge.jsonl


done
