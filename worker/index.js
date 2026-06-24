// Cloudflare Worker that injects Cross-Origin Isolation headers.
// Required for SharedArrayBuffer, which PowerSync's SQLite WASM needs.
// Uses "credentialless" (not "require-corp") so cross-origin resources
// like CanvasKit (gstatic) and the passkeys bundle (GitHub) still load.

const CRITICAL_ASSET_RE = /\.(worker\.js|wasm)$/;

export default {
  async fetch(request, env) {
    let req = request;

    const url = new URL(request.url);
    const isCriticalAsset = CRITICAL_ASSET_RE.test(url.pathname);

    // Strip conditional headers for .worker.js and .wasm so the asset
    // server always returns a full 200 with headers, never a 304.
    if (isCriticalAsset) {
      const headers = new Headers(request.headers);
      headers.delete('If-None-Match');
      headers.delete('If-Modified-Since');
      req = new Request(request, { headers });
    }

    const response = await env.ASSETS.fetch(req);
    const newResponse = new Response(response.body, response);

    newResponse.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
    newResponse.headers.set('Cross-Origin-Embedder-Policy', 'credentialless');
    newResponse.headers.set('Cross-Origin-Resource-Policy', 'same-origin');

    if (isCriticalAsset) {
      newResponse.headers.set('Cache-Control', 'no-cache');
    }

    return newResponse;
  },
};
