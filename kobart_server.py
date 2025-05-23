from flask import Flask, request, jsonify
from transformers import PreTrainedTokenizerFast, BartForConditionalGeneration

app = Flask(__name__)

print("📦 모델 로딩 중...")
tokenizer = PreTrainedTokenizerFast.from_pretrained("digit82/kobart-summarization")
model = BartForConditionalGeneration.from_pretrained("digit82/kobart-summarization")
print("✅ 모델 로딩 완료")

@app.route('/summarize', methods=['POST'])
def summarize():
    try:
        data = request.get_json()
        text = data.get('text', '')

        # 서버에서 프롬프트 문장 추가
        prompt = f"{text} 한 문장으로 요약해줘."

        input_ids = tokenizer.encode(prompt, return_tensors='pt')
        summary_ids = model.generate(
            input_ids,
            max_length=60,
            num_beams=4,
            early_stopping=True,
            no_repeat_ngram_size=2,
            repetition_penalty=2.5,
            length_penalty=1.0,
            num_return_sequences=1
        )
        summary = tokenizer.decode(summary_ids[0], skip_special_tokens=True)

        return jsonify({'summary': summary})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(port=5000)
