const http = require('http');
const url = require('url');

const PORT = 8080;

// Учётные записи трёх ролей для проверки преподом
let users = [
  { id: 1, username: 'admin', email: 'boss@nexus.club', role: 'admin', password: 'Admin@123' },
  { id: 2, username: 'operator', email: 'staff@nexus.club', role: 'operator', password: 'Staff@123' },
  { id: 3, username: 'gamer', email: 'player@nexus.club', role: 'gamer', password: 'Gamer@123' }
];

let zones = [
  { id: 1, name: 'Standard Hall', description: 'Основной зал: мониторы 165Hz, кресла Knight', hourlyPrice: 150.0, deletedAt: null },
  { id: 2, name: 'VIP Neon Room', description: 'Приватная неоновая зона: RTX 4080 Super', hourlyPrice: 350.0, deletedAt: null },
  { id: 3, name: 'Bootcamp Pro 5v5', description: 'Комната для кланваров, звукоизоляция', hourlyPrice: 280.0, deletedAt: null }
];

let computers = [];
for (let i = 1; i <= 22; i++) {
  computers.push({
    id: i,
    name: `NEXUS-${i < 10 ? '0' + i : i}`,
    gpu: i > 15 ? 'RTX 4090' : (i > 8 ? 'RTX 4080' : 'RTX 4070'),
    cpu: i > 15 ? 'Core i9-14900KF' : 'Ryzen 7 7800X3D',
    ramGb: i > 8 ? 32 : 16,
    zoneId: (i % 3) + 1,
    gameIds: [1, 2],
    hourlyRate: 150.0 + (i * 10),
    isVip: i > 15,
    ipAddress: `192.168.1.${100 + i}`,
    deletedAt: null
  });
}

function sendJson(res, statusCode, data) {
  res.writeHead(statusCode, {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
  });
  res.end(JSON.stringify(data));
}

// Извлечение пользователя из подписи токена
function getAuthUser(req) {
  const auth = req.headers['authorization'];
  if (!auth || !auth.startsWith('Bearer ')) return null;
  const token = auth.replace('Bearer ', '').trim();
  const parts = token.split('_');
  if (parts.length >= 3) {
    return { username: parts[1], role: parts[2] };
  }
  return null;
}

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const query = parsedUrl.query;

  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    return res.end();
  }

  // 1. ВХОД: POST /api/auth/login
  if (pathname === '/api/auth/login' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const { username, password } = JSON.parse(body);
      const user = users.find(u => (u.username === username || u.email === username) && u.password === password);
      if (!user) {
        return sendJson(res, 401, { message: 'Неверный логин или пароль' });
      }
      return sendJson(res, 200, {
        accessToken: `token_${user.username}_${user.role}_access`,
        refreshToken: `token_${user.username}_${user.role}_refresh`,
        user: { id: user.id, username: user.username, email: user.email, role: user.role }
      });
    });
    return;
  }

  // 2. РЕГИСТРАЦИЯ: POST /api/auth/register
  if (pathname === '/api/auth/register' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const { username, email, password } = JSON.parse(body);
      if (users.some(u => u.username === username || u.email === email)) {
        return sendJson(res, 422, { message: 'Пользователь с таким именем или email уже существует' });
      }
      const newUser = { id: users.length + 1, username, email, role: 'gamer', password };
      users.push(newUser);
      return sendJson(res, 201, {
        accessToken: `token_${newUser.username}_gamer_access`,
        refreshToken: `token_${newUser.username}_gamer_refresh`,
        user: { id: newUser.id, username: newUser.username, email: newUser.email, role: newUser.role }
      });
    });
    return;
  }

  // 3. SILENT REFRESH: POST /api/auth/refresh
  if (pathname === '/api/auth/refresh' && req.method === 'POST') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      const { refreshToken } = JSON.parse(body);
      if (!refreshToken || !refreshToken.includes('_refresh')) {
        return sendJson(res, 401, { message: 'Срок действия сессии истёк' });
      }
      const parts = refreshToken.split('_');
      const username = parts[1];
      const role = parts[2];
      return sendJson(res, 200, {
        accessToken: `token_${username}_${role}_access`,
        refreshToken: `token_${username}_${role}_refresh`
      });
    });
    return;
  }

  // 4. ТЕКУЩИЙ ПОЛЬЗОВАТЕЛЬ: GET /api/auth/me
  if (pathname === '/api/auth/me' && req.method === 'GET') {
    const auth = getAuthUser(req);
    if (!auth) return sendJson(res, 401, { message: 'Требуется вход в систему' });
    const user = users.find(u => u.username === auth.username);
    if (!user) return sendJson(res, 404, { message: 'Пользователь не найден' });
    return sendJson(res, 200, { id: user.id, username: user.username, email: user.email, role: user.role });
  }

  // 5. ЭКСКЛЮЗИВНЫЙ ЭКРАН АДМИНИСТРАТОРА: GET /api/admin/users
  if (pathname === '/api/admin/users' && req.method === 'GET') {
    const auth = getAuthUser(req);
    if (!auth) return sendJson(res, 401, { message: 'Требуется вход' });
    // Строгая проверка роли на сервере
    if (auth.role !== 'admin') {
      return sendJson(res, 403, { message: 'Доступ запрещён! Требуются права Администратора (Admin).' });
    }
    return sendJson(res, 200, users.map(u => ({ id: u.id, username: u.username, email: u.email, role: u.role })));
  }

  // 6. СЕРВЕРНАЯ ПРОВЕРКА ПРАВ ДЛЯ ПУНКТА 17 (Защита от подмены роли на клиенте)
  const authUser = getAuthUser(req);

  // Создание / Редактирование ПК (запрещено роли gamer!)
  if (pathname === '/api/computers' && (req.method === 'POST' || req.method === 'PUT')) {
    if (!authUser || authUser.role === 'gamer') {
      return sendJson(res, 403, { message: 'Отказ доступа (403): Гостям клуба (Gamer) запрещено изменять конфигурацию оборудования!' });
    }
  }

  // Полное удаление (только admin!)
  if (pathname.startsWith('/api/computers/') && req.method === 'DELETE' && query.hard === 'true') {
    if (!authUser || authUser.role !== 'admin') {
      return sendJson(res, 403, { message: 'Отказ доступа (403): Полное удаление ПК разрешено только Администратору!' });
    }
  }

  // Обычные запросы
  if (pathname === '/api/computers' && req.method === 'GET') {
    let filtered = computers.filter(c => query.includeDeleted === 'true' || !c.deletedAt);
    if (query.search) {
      const s = query.search.toLowerCase();
      filtered = filtered.filter(c => c.name.toLowerCase().includes(s) || c.gpu.toLowerCase().includes(s));
    }
    const page = parseInt(query.page || '1', 10);
    const size = parseInt(query.size || '10', 10);
    const total = filtered.length;
    const start = (page - 1) * size;
    const items = filtered.slice(start, start + size);
    return sendJson(res, 200, { items, page, size, total });
  }

  if (pathname === '/api/zones' && req.method === 'GET') {
    return sendJson(res, 200, zones);
  }

  sendJson(res, 404, { message: 'Маршрут не найден' });
});

server.listen(PORT, () => {
  console.log(`[OK] Nexus Club Auth Server running at http://localhost:${PORT}/api`);
});