export default async function handler(request) {
  const cors = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type",
    "Cache-Control": "s-maxage=60, stale-while-revalidate=300",
    "Content-Type": "application/json; charset=utf-8",
  };

  if (request.method === "OPTIONS") {
    return new Response(null, { status: 204, headers: cors });
  }

  const requestUrl = new URL(request.url);
  const endpoint = (requestUrl.searchParams.get("endpoint") || "tracks")
    .replace(/^\/+|\/+$/g, "");
  const allowed = new Set(["tracks", "artists", "albums"]);

  if (!allowed.has(endpoint)) {
    return new Response(
      JSON.stringify({ error: "Invalid music endpoint." }),
      { status: 400, headers: cors },
    );
  }

  const clientId = String(process.env.JAMENDO_CLIENT_ID || "709fa152").trim();
  if (!clientId) {
    return new Response(
      JSON.stringify({ error: "JAMENDO_CLIENT_ID is not configured." }),
      { status: 500, headers: cors },
    );
  }

  const params = new URLSearchParams();
  params.set("client_id", clientId);
  params.set("format", "json");

  for (const [key, value] of requestUrl.searchParams.entries()) {
    if (key === "endpoint" || key === "client_id" || value.length === 0) continue;
    params.set(key, value);
  }

  const upstreamUrl = `https://api.jamendo.com/v3.0/${endpoint}/?${params.toString()}`;

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 12000);

    let upstream;
    try {
      upstream = await fetch(upstreamUrl, {
        method: "GET",
        headers: { accept: "application/json" },
        signal: controller.signal,
      });
    } finally {
      clearTimeout(timeout);
    }

    const body = await upstream.text();

    if (!upstream.ok) {
      return new Response(
        JSON.stringify({
          error: `Jamendo upstream HTTP ${upstream.status}.`,
          detail: body.slice(0, 1000),
        }),
        { status: 502, headers: cors },
      );
    }

    return new Response(body, { status: 200, headers: cors });
  } catch (error) {
    console.error("Jamendo proxy error:", error);
    const message =
      error?.name === "AbortError"
        ? "Jamendo request timed out."
        : error instanceof Error
          ? error.message
          : String(error);

    return new Response(
      JSON.stringify({
        error: "Jamendo request failed.",
        detail: message,
      }),
      { status: 502, headers: cors },
    );
  }
}
