const http = require('http');
const fs = require('fs');
const path = require('path');
const url = require('url');

const PORT = 3000;
const DOCS_DIR = path.join(__dirname, 'docs');

// config.js에서 API 키 읽기
const configPath = path.join(DOCS_DIR, 'js', 'config.js');
const configSrc = fs.readFileSync(configPath, 'utf8');
const apiKeyMatch = configSrc.match(/SEOUL_TOILET_API_KEY:\s*['"]([^'"]+)['"]/);
const SEOUL_API_KEY = apiKeyMatch ? apiKeyMatch[1] : '';

const MIME = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css',
  '.js': 'application/javascript',
  '.json': 'application/json',
  '.png': 'image/png',
  '.ico': 'image/x-icon',
};

const server = http.createServer((req, res) => {
  const parsed = url.parse(req.url, true);
  const pathname = parsed.pathname;

  res.setHeader('Access-Control-Allow-Origin', '*');

  // 서울 공중화장실 API 프록시
  if (pathname === '/api/toilets') {
    const start = parseInt(parsed.query.start) || 1;
    const end = parseInt(parsed.query.end) || 1000;
    const apiUrl = `http://openapi.seoul.go.kr:8088/${SEOUL_API_KEY}/json/mgisToiletPoi/${start}/${end}/`;

    const apiReq = http.get(apiUrl, (apiRes) => {
      let data = '';
      apiRes.on('data', chunk => (data += chunk));
      apiRes.on('end', () => {
        res.setHeader('Content-Type', 'application/json; charset=utf-8');
        res.end(data);
      });
    });
    apiReq.on('error', (e) => {
      res.statusCode = 502;
      res.end(JSON.stringify({ error: e.message }));
    });
    return;
  }

  // 정적 파일 서빙
  const filePath = path.join(
    DOCS_DIR,
    pathname === '/' ? 'index.html' : pathname
  );

  fs.readFile(filePath, (err, data) => {
    if (err) {
      res.statusCode = 404;
      res.end('Not found');
      return;
    }
    const ext = path.extname(filePath);
    res.setHeader('Content-Type', MIME[ext] || 'text/plain');
    res.end(data);
  });
});

server.listen(PORT, () => {
  console.log(`\n🚻 볼일봐 서버 실행 중: http://localhost:${PORT}\n`);
});
