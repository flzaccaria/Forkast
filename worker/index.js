// Cloudflare Worker that injects Cross-Origin Isolation headers.
// Required for SharedArrayBuffer, which PowerSync's SQLite WASM needs.
// Uses "credentialless" (not "require-corp") so cross-origin resources
// like CanvasKit (gstatic) and the passkeys bundle (GitHub) still load.
export default {
  async fetch(request, env) {
    const response = await env.ASSETS.fetch(request);
    const newResponse = new Response(response.body, response);
    newResponse.headers.set('Cross-Origin-Opener-Policy', 'same-origin');
    newResponse.headers.set('Cross-Origin-Embedder-Policy', 'credentialless');
    return newResponse;
  },
};
