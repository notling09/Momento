// Winziger Webserver ohne Abhaengigkeiten, um die Website lokal anzusehen.
//   node tool/serve_website.js               -> Website auf http://127.0.0.1:5050
//   node tool/serve_website.js build/web     -> beliebiger Ordner
const http = require('http');
const fs = require('fs');
const path = require('path');

// Ordner als Argument, Vorgabe ist die Website.
const root = path.resolve(process.argv[2] || path.join(__dirname, '..', 'website'));
const port = process.env.PORT || 5050;
const types = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'text/javascript; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml',
  '.apk': 'application/vnd.android.package-archive',
};

http.createServer((req, res) => {
  const url = decodeURIComponent(req.url.split('?')[0]);
  let file = path.join(root, url === '/' ? 'index.html' : url);
  if (!file.startsWith(root)) { res.writeHead(403).end('nope'); return; }
  if (fs.existsSync(file) && fs.statSync(file).isDirectory()) file = path.join(file, 'index.html');
  if (!fs.existsSync(file)) { res.writeHead(404).end('nicht gefunden'); return; }
  res.writeHead(200, { 'Content-Type': types[path.extname(file)] || 'application/octet-stream' });
  fs.createReadStream(file).pipe(res);
}).listen(port, '127.0.0.1', () => console.log(`Website laeuft auf http://127.0.0.1:${port}`));
