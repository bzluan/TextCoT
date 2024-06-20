# TextCoT
<p>
    <a href='https://arxiv.org/abs/2404.09797' target="_blank"><img src='https://img.shields.io/badge/Paper-Arxiv-red'></a>
</p>

This is the implementation of the paper [TextCoT: Zoom In for Enhanced Multimodal Text-Rich Image Understanding](https://drive.google.com/file/d/1AY13sdAqsx54ecfeijFk5nETeecxfb2H/view?usp=sharing)

![方法框图-final_v6](https://github.com/lbz0075/TextCoT/assets/74731678/5c1f64f8-39d2-4c15-ad29-b8bf2ba9cdd0)


The advent of Large Multimodal Models (LMMs) has sparked a surge in research aimed at harnessing their remarkable reasoning abilities. However, for understanding text-rich images, challenges persist in fully leveraging the potential of LMMs, and existing methods struggle with effectively processing high-resolution images. In this work, we propose TextCoT, a novel Chain-of-Thought framework for text-rich image understanding. TextCoT utilizes the captioning ability of LMMs to grasp the global context of the image and the grounding capability to examine local textual regions. This allows for the extraction of both global and local visual information, facilitating more accurate question-answering. Technically, TextCoT consists of three stages, including image overview, coarse localization, and fine-grained observation. The image overview stage provides a comprehensive understanding of the global scene information, and the coarse localization stage approximates the image area containing the answer based on the question asked. Then, integrating the obtained global image descriptions, the final stage further examines specific regions to provide accurate answers. Our method is free of extra training, offering immediate plug-and-play functionality. Extensive experiments are conducted on a series of text-rich image question-answering benchmark datasets based on several advanced LMMs, and the results demonstrate the effectiveness and strong generalization ability of our method.

# Datasets
From https://github.com/Yuliang-Liu/MultimodalOCR

Test Json: [Full Test](./FullTest.json)

All Test Images: [All Images](https://drive.google.com/file/d/1U5AtLoJ7FrJe9yfcbssfeLmlKb7dTosc/view?usp=drive_link)

# Large Multimodal Models
LLaVA-1.5-7B & LLaVA-1.5-13B: https://github.com/haotian-liu/LLaVA
SPHINX: https://github.com/sphinx-doc/sphinx
ShareGPT4V: https://github.com/ShareGPT4Omni/ShareGPT4V
Qwen-VL-Chat: https://github.com/QwenLM/Qwen-VL

# Evaluation

Example evaluation scripts:

```
bash TextCoT_evaluation.sh
```

# Acknowledgement

Our work is inspired by [CCOT](https://github.com/chancharikmitra/CCoT). We are grateful for their great work.

# Citation

Please cite the related works in your publications if it helps your research:

```
@article{textcot,
  title={TextCoT: Zoom In for Enhanced Multimodal Text-Rich Image Understanding},
  author={Luan, Bozhi and Feng, Hao and Chen, Hong and Wang, Yonghui and Zhou, Wengang and Li, Houqiang},
  journal={arXiv preprint arXiv:2404.09797},
  year={2024}
}
```
