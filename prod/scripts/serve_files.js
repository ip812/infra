addEventListener("fetch", event => {
    event.respondWith(handleRequest(event));
});

async function handleRequest(event) {
    const request = event.request;
    const url = new URL(request.url);
    const key = url.pathname.slice(1);

    if (request.method !== "GET") {
        return new Response("Method Not Allowed", { status: 405 });
    }

    const object = await event.env.FILES_BUCKET.get(key);
    if (!object) return new Response("Not found", { status: 404 });

    const headers = new Headers();
    object.writeHttpMetadata(headers);
    headers.set("etag", object.httpEtag);

    return new Response(object.body, { headers });
}
