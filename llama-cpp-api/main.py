import requests
import json
import sys

base_url = "http://localhost:8000/v1"
model = "gemma3-4b-it"

def chat(message):
  payload = {
      "model": model,
      "messages": [
          {"role": "user", "content": message}
      ],
      "stream": True,
      "temperature": 1.0
  }

  with requests.post(f"{base_url}/chat/completions", json=payload, stream=True) as chat_response:
    for chunk in chat_response.iter_content(chunk_size=None):
      if chunk:
        raw_json = chunk.decode('utf-8')
        if raw_json == "[DONE]":
          break

        if raw_json.startswith("data: "):
          raw_json = raw_json[6:]

        response_json = json.loads(raw_json)

        choices = response_json.get("choices", None)
        if choices is None or len(choices) == 0:
          raise Exception("Invalid response from the server.")

        finish_reason = choices[0].get("finish_reason", None)
        if finish_reason == "stop":
          break

        delta = choices[0].get("delta", None)
        if delta is None:
          raise Exception("Message did not exist in the response.")

        content = delta.get("content", None)
        if content is None:
          raise Exception("Content did not exist in the response.")

        # Phew, finally yield back the content!
        yield content


if len(sys.argv) < 2:
  message = "Hello, how are you?"
else:
  message = sys.argv[1]

for response in chat(message):
  print(response, end="", flush=True)

print()