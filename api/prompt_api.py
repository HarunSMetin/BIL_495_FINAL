import openai

#Our OpenAI API key
openai.api_key = 'OPENAI_API_KEY'

#path_to_prompt = "prompt.txt"

def get_prompt(prompt_file_path):
    with open(prompt_file_path, 'r') as file:
        prompt = file.read()
        return prompt

def generate_prompt(from_location, to_location):
    return f"From: {from_location}\nTo: {to_location}\nChatGPT:"

def generate_response(prompt):
    response = openai.Completion.create(
        engine="text-davinci-002",
        prompt=prompt,
        max_tokens=150,
        temperature=0.7
    )
    return response.choices[0].text.strip()

def main():
    from_location = "New York"
    to_location = "Los Angeles"

    # Generate the initial prompt
    prompt = generate_prompt(from_location, to_location)

    while True:
        user_input = input(generate_prompt(from_location, to_location) + " ")

        #Generate and print the model's response
        response = generate_response(user_input)
        print(response)

if __name__ == "__main__":
    main()
