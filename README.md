# llm-laptop
LLMs on a laptop - You can have fun without a big GPU :)

## llama-cpp-setup

This assumes your system has an iGPU either: Radeon or Arc.
Because of this, I chose to just assume the Vulkan backend.

Helper scripts for initial setup for Debian and Fedora-based systems.

`upgrade_llama_cpp.sh` is a good utility to keep your local `llama.cpp` up to date and at the bleeding edge.

Model of choice: `gemma-4-E4B-it`. Previous iterations of these setup scripts from myself had used `gemma-3-4B` - but that is now a very old model in comparison to all the cool stuff out there today...