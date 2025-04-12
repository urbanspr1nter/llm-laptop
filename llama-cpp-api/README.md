# llama.cpp API Request Example

Simple Python demonstration in how to use `llama.cpp` API to perform inference on an LLM with **streaming**.

## Prerequisites

Follow this guide to set up `llama.cpp` for CPU inferencing on any model: [llama.cpp Build Guide for CPU Inferencing](https://www.roger.lol/blog/llamacpp-build-guide-for-cpu-inferencing)

## Setup

1. Create a virtual environment:

```bash
python3 -m venv .venv
source .venv/bin/activate
```

2. Install dependencies:

```bash
pip install -r requirements.txt
```

## Usage

You will just need to modify the base API url in the `main.py` script. Once done you can run the program like this:

```bash
python main.py "hello, can you tell me about your training?"
```

Shortly, you'll start to see the model stream back the content of the response.
