const http = require('http');
const url = require('url');

const PORT = 8080;
const ALLOWED_ORIGIN = 'http://localhost:5555';

// Начальные данные сервера
let zones = [
  { id: 1, name: 'Standard Hall', description: 'Основной зал: мониторы 165Hz, кресла Knight, периферия HyperX', hourlyPrice: 150.0, deletedAt: null },
  { id: 2, name: 'VIP Neon Room', description: 'Приватная неоновая зона: RTX 4080 Super, 280Hz ASUS ROG', hourlyPrice: 350.0, deletedAt: null },
  { id: 3, name: 'Bootcamp Pro 5v5', description: 'Шумоизолированная комната для кланваров, сетап 360Hz ZOWIE', hourlyPrice: 280.0, deletedAt: null },
  { id: 4, name: 'Streamer Studio', description: 'Студийный свет Elgato, Shure SM7B, зеркальная 4K камера', hourlyPrice: 500.0, deletedAt: null },
  { id: 5, name: 'PlayStation 5 Lounge', description: 'Диваны, PS5 Pro, 4K OLED панели 65" 120Hz', hourlyPrice: 200.0, deletedAt: null },
  { id: 6, name: 'VR Cyber Arena', description: 'Meta Quest 3 + Valve Index, трекинг всего тела', hourlyPrice: 400.0, deletedAt: null },
  { id: 7, name: 'Tournament Stage', description: 'Главная сцена с посадочными местами для чемпионатов', hourlyPrice: 450.0, deletedAt: null },
  { id: 8, name: 'Chill & Smoke Bar', description: 'Барная стойка с трансляциями Twitch и напитками', hourlyPrice: 100.0, deletedAt: null }
];

let games = [
  { id: 1, title: 'Counter-Strike 2', genre: 'Тактический шутер', storageGb: 40, deletedAt: null },
  { id: 2, title: 'Dota 2', genre: 'MOBA', storageGb: 45, deletedAt: null },
  { id: 3, title: 'Cyberpunk 2077: Phantom Liberty', genre: 'Action RPG', storageGb: 85, deletedAt: null },
  { id: 4, title: 'Valorant', genre: 'Тактический шутер', storageGb: 35, deletedAt: null },
  { id: 5, title: 'Grand Theft Auto V', genre: 'Экшен', storageGb: 110, deletedAt: null },
  { id: 6, title: 'Apex Legends', genre: 'Королевская битва', storageGb: 65, deletedAt: null }
];

let tariffs = [
  { id: 1, name: 'Пакет 3 часа (Standard)', zoneId: 1, durationHours: 3, price: 400, deletedAt: null },
  { id: 2, name: 'Пакет 5 часов (Standard)', zoneId: 1, durationHours: 5, price: 600, deletedAt: null },
  { id: 3, name: 'Ночной Non-Stop (Standard)', zoneId: 1, durationHours: 8, price: 850, deletedAt: null },
  { id: 4, name: 'Пакет 3 часа (VIP)', zoneId: 2, durationHours: 3, price: 900, deletedAt: null },
  { id: 5, name: 'Пакет 5 часов (VIP)', zoneId: 2, durationHours: 1400, price: 1400, deletedAt: null },
  { id: 6, name: 'Ночной Non-Stop (VIP)', zoneId: 2, durationHours: 8, price: 2000, deletedAt: null }
];

let members = [
  { id: 1, nickname: 'ShadowSlayer', email: 'shadow@nexus.club', phone: '+7 (999) 111-22-33', card: { cardNumber: 'NEXUS-7701', discountPercent: 15, bonusBalance: 1250 }, deletedAt: null },
  { id: 2, nickname: 'CyberViper', email: 'viper@nexus.club', phone: '+7 (999) 222-33-44', card: { cardNumber: 'NEXUS-7702', discountPercent: 10, bonusBalance: 800 }, deletedAt: null },
  { id: 3, nickname: 'FrostBite', email: 'frost@nexus.club', phone: '+7 (999) 333-44-55', card: { cardNumber: 'NEXUS-7703', discountPercent: 5, bonusBalance: 300 }, deletedAt: null },
  { id: 4, nickname: 'NeoMatrix', email: 'neo@nexus.club', phone: '+7 (999) 444-55-66', card: { cardNumber: 'NEXUS-7704', discountPercent: 20, bonusBalance: 3500 }, deletedAt: null }
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
    gameIds: [1, 2, (i % 4) + 1],
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

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const query = parsedUrl.query;

  // Обработка Preflight CORS-запросов
  if (req.method === 'OPTIONS') {
    res.writeHead(204, {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization'
    });
    return res.end();
  }

  // Эмуляция задержки сети (?__delay=1500)
  const delay = query.__delay ? parseInt(query.__delay, 10) : 50;

  setTimeout(() => {
    // Эмуляция сбоя сервера (?__fail=500)
    if (query.__fail) {
      return sendJson(res, parseInt(query.__fail, 10), { message: 'Искусственный сбой сервера (тестирование)' });
    }

    // 1. Health check
    if (pathname === '/api/__health') {
      return sendJson(res, 200, { status: 'OK', service: 'Nexus Club Mock Server' });
    }

    // 2. GET /api/zones
    if (pathname === '/api/zones' && req.method === 'GET') {
      return sendJson(res, 200, zones.filter(z => !z.deletedAt));
    }

    // DELETE /api/zones/:id с проверкой 409 Conflict
    if (pathname.startsWith('/api/zones/') && req.method === 'DELETE') {
      const id = parseInt(pathname.split('/')[3], 10);
      const linked = computers.filter(c => c.zoneId === id && !c.deletedAt);
      if (linked.length > 0) {
        return sendJson(res, 409, { message: `Невозможно удалить зону: к ней привязано ${linked.length} ПК` });
      }
      zones = zones.filter(z => z.id !== id);
      return sendJson(res, 200, { success: true });
    }

    // 3. GET /api/games
    if (pathname === '/api/games' && req.method === 'GET') {
      return sendJson(res, 200, games.filter(g => !g.deletedAt));
    }

    // 4. GET /api/tariffs
    if (pathname === '/api/tariffs' && req.method === 'GET') {
      let result = tariffs;
      if (query.zoneId) {
        result = result.filter(t => t.zoneId === parseInt(query.zoneId, 10));
      }
      return sendJson(res, 200, result);
    }

    // 5. GET /api/members
    if (pathname === '/api/members' && req.method === 'GET') {
      return sendJson(res, 200, members.filter(m => !m.deletedAt));
    }

    // 6. COMPUTERS CRUD + Server Pagination & Filtering (Критерий 12)
    if (pathname === '/api/computers' && req.method === 'GET') {
      let filtered = computers.filter(c => query.includeDeleted === 'true' || !c.deletedAt);

      if (query.search) {
        const s = query.search.toLowerCase();
        filtered = filtered.filter(c => c.name.toLowerCase().includes(s) || c.gpu.toLowerCase().includes(s) || c.cpu.toLowerCase().includes(s));
      }
      if (query.zoneId) {
        filtered = filtered.filter(c => c.zoneId === parseInt(query.zoneId, 10));
      }
      if (query.isVip) {
        filtered = filtered.filter(c => c.isVip === (query.isVip === 'true'));
      }

      // Сортировка на сервере
      const sortField = query.sort || 'name';
      const isAsc = query.desc !== 'true';
      filtered.sort((a, b) => {
        let valA = a[sortField];
        let valB = b[sortField];
        if (typeof valA === 'string') valA = valA.toLowerCase();
        if (typeof valB === 'string') valB = valB.toLowerCase();
        if (valA < valB) return isAsc ? -1 : 1;
        if (valA > valB) return isAsc ? 1 : -1;
        return 0;
      });

      // Постраничная нарезка на сервере
      const page = parseInt(query.page || '1', 10);
      const size = parseInt(query.size || '10', 10);
      const total = filtered.length;
      const start = (page - 1) * size;
      const items = filtered.slice(start, start + size);

      return sendJson(res, 200, { items, page, size, total });
    }

    // POST /api/computers (Создание с валидацией 422)
    if (pathname === '/api/computers' && req.method === 'POST') {
      let body = '';
      req.on('data', chunk => body += chunk);
      req.on('end', () => {
        const data = JSON.parse(body);
        // Валидация уникальности IP на сервере
        if (computers.some(c => c.ipAddress === data.ipAddress)) {
          return sendJson(res, 422, {
            message: 'Ошибка валидации',
            errors: { ipAddress: 'Этот IP-адрес уже зарегистрирован на сервере' }
          });
        }
        const newId = computers.length ? Math.max(...computers.map(c => c.id)) + 1 : 1;
        const newComp = { ...data, id: newId, deletedAt: null };
        computers.push(newComp);
        return sendJson(res, 201, newComp);
      });
      return;
    }

    // PUT /api/computers/:id
    if (pathname.startsWith('/api/computers/') && req.method === 'PUT') {
      const id = parseInt(pathname.split('/')[3], 10);
      let body = '';
      req.on('data', chunk => body += chunk);
      req.on('end', () => {
        const data = JSON.parse(body);
        const index = computers.findIndex(c => c.id === id);
        if (index === -1) return sendJson(res, 404, { message: 'ПК не найден' });

        // Проверка уникальности IP при редактировании
        if (computers.some(c => c.ipAddress === data.ipAddress && c.id !== id)) {
          return sendJson(res, 422, {
            message: 'Ошибка валидации',
            errors: { ipAddress: 'Этот IP-адрес занят другим ПК' }
          });
        }

        computers[index] = { ...data, id };
        return sendJson(res, 200, computers[index]);
      });
      return;
    }

    // DELETE /api/computers/:id
    if (pathname.startsWith('/api/computers/') && req.method === 'DELETE') {
      const id = parseInt(pathname.split('/')[3], 10);
      const index = computers.findIndex(c => c.id === id);
      if (index !== -1) {
        if (query.hard === 'true') {
          computers.splice(index, 1);
        } else {
          computers[index].deletedAt = new Date().toISOString();
        }
      }
      return sendJson(res, 200, { success: true });
    }

    // POST /api/computers/bulk-delete
    if (pathname === '/api/computers/bulk-delete' && req.method === 'POST') {
      let body = '';
      req.on('data', chunk => body += chunk);
      req.on('end', () => {
        const { ids } = JSON.parse(body);
        let count = 0;
        ids.forEach(id => {
          const comp = computers.find(c => c.id === id);
          if (comp && !comp.deletedAt) {
            comp.deletedAt = new Date().toISOString();
            count++;
          }
        });
        return sendJson(res, 200, { deleted: count });
      });
      return;
    }

    // 404
    sendJson(res, 404, { message: 'Маршрут не найден на сервере' });
  }, delay);
});

server.listen(PORT, () => {
  console.log(`[OK] Mock REST API Server running at http://localhost:${PORT}/api`);
  console.log(`[OK] Health check: http://localhost:${PORT}/api/__health`);
});