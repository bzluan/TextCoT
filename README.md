# TextCoT: Zoom In for Enhanced Multimodal Text-Rich Image Understanding
<p>
    <a href='https://drive.google.com/file/d/1_2HKI3HWCk6YGuZg58wa4R7vzx6dVV6I/view?usp=drive_link' target="_blank"><img src='https://img.shields.io/badge/Paper-Arxiv-red'></a>
</p>

This is a PyTorch/GPU re-implementation of the paper [TextCoT: Zoom In for Enhanced Multimodal Text-Rich Image Understanding](https://drive.google.com/file/d/1_2HKI3HWCk6YGuZg58wa4R7vzx6dVV6I/view?usp=drive_link)

![方法框图-final_v6](https://github.com/lbz0075/TextCoT/assets/74731678/5c1f64f8-39d2-4c15-ad29-b8bf2ba9cdd0)


The advent of Large Multimodal Models (LMMs) has sparked a surge in research aimed at harnessing their remarkable reasoning abilities. However, for understanding text-rich images, challenges persist in fully leveraging the potential of LMMs, and existing methods struggle with effectively processing high-resolution images. In this work, we propose TextCoT, a novel Chain-of-Thought framework for text-rich image understanding. TextCoT utilizes the captioning ability of LMMs to grasp the global context of the image and the grounding capability to examine local textual regions. This allows for the extraction of both global and local visual information, facilitating more accurate question-answering. Technically, TextCoT consists of three stages, including image overview, coarse localization, and fine-grained observation. The image overview stage provides a comprehensive understanding of the global scene information, and the coarse localization stage approximates the image area containing the answer based on the question asked. Then, integrating the obtained global image descriptions, the final stage further examines specific regions to provide accurate answers. Our method is free of extra training, offering immediate plug-and-play functionality. Extensive experiments are conducted on a series of text-rich image question-answering benchmark datasets based on several advanced LMMs, and the results demonstrate the effectiveness and strong generalization ability of our method.

# Datasets
From https://github.com/Yuliang-Liu/MultimodalOCR

Test Json: [Full Test](./FullTest.json)

All Test Images: [All Images](https://drive.google.com/file/d/1U5AtLoJ7FrJe9yfcbssfeLmlKb7dTosc/view?usp=drive_link)

# Evaluation

Example evaluation scripts:

```
bash scripts/TextCoT_evaluation.sh
```
