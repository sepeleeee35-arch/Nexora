export default async function handler(req, res) {
  const allowed = new Set(['tracks', 'artists', 'albums']);
  const endpoint = String(req.query?.endpoint || 'tracks');
  if (!allowed.has(endpoint)) {
    return res.status(400).json({ error: 'Invalid music endpoint.' });
  }

  const clientId = process.env.JAMENDO_CLIENT_ID || '709fa152';
  const params = new URLSearchParams();
  params.set('client_id', clientId);
  params.set('format', 'json');

  const incoming = req.query || {};
  for (const [key, value] of Object.entries(incoming)) {
    if (key === 'endpoint') continue;
    if (value == null) continue;
    params.set(key, Array.isArray(value) ? value[0] : String(value));
  }

  const url = 'https://api.jamendo.com/v3.0/' + endpoint + '/?' + params.toString();

  try {
    const upstream = await fetch(url, {
      headers: { accept: 'application/json' },
    });
    const body = await upstream.text();
    res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    return res.status(upstream.status).send(body);
  } catch (error) {
    return res.status(502).json({
      error: 'Jamendo request failed.',
      detail: error instanceof Error ? error.message : String(error),
    });
  }
}
