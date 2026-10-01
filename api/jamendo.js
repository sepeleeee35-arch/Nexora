export default async function handler(req, res) {
  const endpoint = String(req.query?.endpoint || 'tracks').replace(/^\/+|\/+$/g, '');
  const allowed = new Set(['tracks', 'artists', 'albums', 'charts/track']);

  if (!allowed.has(endpoint)) {
    return res.status(400).json({ error: 'Invalid music endpoint.' });
  }

  const clientId = String(process.env.JAMENDO_CLIENT_ID || '709fa152').trim();
  if (!clientId) {
    return res.status(500).json({ error: 'JAMENDO_CLIENT_ID is not configured.' });
  }

  const params = new URLSearchParams({
    client_id: clientId,
    format: 'json',
  });

  const query = req.query || {};
  for (const [key, value] of Object.entries(query)) {
    if (key === 'endpoint' || key === 'client_id' || value == null) continue;
    const first = Array.isArray(value) ? value[0] : value;
    if (first != null && String(first).length > 0) {
      params.set(key, String(first));
    }
  }

  const url = `https://api.jamendo.com/v3.0/${endpoint}/?${params.toString()}`;

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 12000);

    let upstream;
    try {
      upstream = await fetch(url, {
        method: 'GET',
        headers: { accept: 'application/json' },
        signal: controller.signal,
      });
    } finally {
      clearTimeout(timeout);
    }

    const body = await upstream.text();

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.setHeader('Cache-Control', 's-maxage=60, stale-while-revalidate=300');
    res.setHeader('Content-Type', 'application/json; charset=utf-8');

    if (!upstream.ok) {
      return res.status(502).json({
        error: `Jamendo upstream HTTP ${upstream.status}.`,
        detail: body.slice(0, 1000),
      });
    }

    return res.status(200).send(body);
  } catch (error) {
    console.error('Jamendo proxy error:', error);
    const message = error?.name === 'AbortError'
      ? 'Jamendo request timed out.'
      : (error instanceof Error ? error.message : String(error));

    res.setHeader('Access-Control-Allow-Origin', '*');
    return res.status(502).json({
      error: 'Jamendo request failed.',
      detail: message,
    });
  }
}