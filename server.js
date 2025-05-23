const express = require('express');
const axios = require('axios');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const SUMMARY_API_URL = 'http://127.0.0.1:5000/summarize';  // 로컬 Flask KoBART 서버 주소

app.post('/summarize', async (req, res) => {
  let { text } = req.body;
  console.log('📥 요청 수신:', text);

  // 프롬프트를 텍스트 앞에 붙여서 명령문으로 만듭니다.
  const promptText = `다음 문장을 한 문장으로 요약해줘:\n${text}`;

  try {
    const response = await axios.post(SUMMARY_API_URL, { text: promptText });
    const summary = response.data.summary || '요약 실패';
    console.log('✅ 요약 결과:', summary);
    res.json({ summary });
  } catch (error) {
    console.error('❌ 요약 에러:', error.message);
    res.status(500).json({ error: '요약 실패', detail: error.message });
  }
});

const PORT = 3000;
app.listen(PORT, () => {
  console.log(`🚀 서버 실행 중: http://localhost:${PORT}`);
});
