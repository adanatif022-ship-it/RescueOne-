const http = require('http');
const fs = require('fs');
const path = require('path');

const ROOT_DIR = __dirname;
let PORT = 8085;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.jpeg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.ico': 'image/x-icon',
  '.apk': 'application/vnd.android.package-archive',
  '.pdf': 'application/pdf',
  '.woff2': 'font/woff2',
  '.wasm': 'application/wasm'
};

const server = http.createServer((req, res) => {
  let reqPath;
  try {
    reqPath = decodeURIComponent(req.url.split('?')[0]);
  } catch (_) {
    res.writeHead(400);
    res.end('Bad Request');
    return;
  }
  // Folders serve their index.html, like Netlify/Vercel do (e.g. /app/).
  if (reqPath === '' || reqPath.endsWith('/')) {
    reqPath += 'index.html';
  }

  const safePath = path.normalize(path.join(ROOT_DIR, reqPath));
  // Must be inside ROOT_DIR itself - not a sibling folder whose name merely
  // starts with the same text (e.g. "... - Copy (2)").
  if (safePath !== ROOT_DIR && !safePath.startsWith(ROOT_DIR + path.sep)) {
    res.writeHead(403);
    res.end('Forbidden');
    return;
  }

  fs.stat(safePath, (err, stats) => {
    if (!err && stats.isDirectory()) {
      // /app -> /app/ so the app's relative paths resolve inside the folder.
      // The target is rebuilt from the resolved path, never from the raw
      // request, so "//host" can't turn it into a redirect to another site.
      const rel = path
        .relative(ROOT_DIR, safePath)
        .split(path.sep)
        .map(encodeURIComponent)
        .join('/');
      res.writeHead(301, { Location: rel ? `/${rel}/` : '/' });
      res.end();
      return;
    }
    if (err || !stats.isFile()) {
      res.writeHead(404, { 'Content-Type': 'text/plain; charset=utf-8' });
      res.end('404 Not Found');
      return;
    }

    const ext = path.extname(safePath).toLowerCase();
    const contentType = MIME_TYPES[ext] || 'application/octet-stream';

    res.writeHead(200, {
      'Content-Type': contentType,
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Access-Control-Allow-Origin': '*'
    });

    const stream = fs.createReadStream(safePath);
    stream.pipe(res);
  });
});

server.on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    PORT++;
    server.listen(PORT, '127.0.0.1');
  } else {
    console.error('Server error:', err);
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`RESCUE_ONE_SERVER_RUNNING: http://localhost:${PORT}`);
  console.log(`RESCUE_ONE_SERVER_RUNNING: http://127.0.0.1:${PORT}`);
});
