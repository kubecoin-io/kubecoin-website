export async function onRequest(context) {
  const clientId = context.env.GITHUB_CLIENT_ID;
  const clientSecret = context.env.GITHUB_CLIENT_SECRET;
  const code = new URL(context.request.url).searchParams.get('code');

  const tokenResponse = await fetch('https://github.com/login/oauth/access_token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify({ client_id: clientId, client_secret: clientSecret, code }),
  });

  const tokenData = await tokenResponse.json();
  const token = tokenData.access_token;

  return new Response(`<script>window.opener.postMessage('${token}', '*'); window.close();</script>`, {
    headers: { 'Content-Type': 'text/html' },
  });
}