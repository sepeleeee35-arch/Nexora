export default async function handler(req, res) {
  const endpoint = String(req.query?.endpoint || 'tracks').replace(/^\/+|\/+$/g, '');
  const allowed = new Set(['tracks', 'artists', 'albums']);

  if (!allowed.has(endpoint)) {
    return res.status(400).json({ error: 'Invalid music endpoint.' });
  }

  const clientId = String(process.env.JAMENDO_CLIENT_ID || '709fa152').trim();
  if (!clientId) {
    return res.status(500).json({ error: 'JAMENDO_CLIENT_ID is not configured.' });
  }

  const params = new URLSearchParams();
  params.set('client_id', clientId);
  params.set('format', 'json');

  const query = req.query || {};
  for (const [key, value] of Object.entries(query)) {
    if (key === 'endpoint' || value == null) continue;
    params.set(key, Array.isArray(value) ? String(value[0]) : String(value));
  }

  const url = `https://api.jamendo.com/v3.0/${endpoint}/?${params.toString()}`;

  try {
    const upstream = await fetch(url, {
      method: 'GET',
      headers: { accept: 'application/json' },
    });

    const body = await upstream.text();

    res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');
    return res.status(upstream.status).send(body);
  } catch (error) {
    console.error('Jamendo proxy error:', error);
    return res.status(502).json({
      error: 'Jamendo request failed.',
      detail: error instanceof Error ? error.message : String(error),
    });
  }
}
