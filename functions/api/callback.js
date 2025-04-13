// This function handles the callback from GitHub OAuth
export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  
  if (!code) {
    return new Response("No code provided", { status: 400 });
  }
  
  // Exchange the code for an access token
  const tokenResponse = await fetch("https://github.com/login/oauth/access_token", {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Accept": "application/json"
    },
    body: JSON.stringify({
      client_id: env.GITHUB_CLIENT_ID,
      client_secret: env.GITHUB_CLIENT_SECRET,
      code: code
    })
  });
  
  const tokenData = await tokenResponse.json();
  
  if (tokenData.error) {
    return new Response(`Error: ${tokenData.error}`, { status: 400 });
  }
  
  // Redirect back to the admin interface with the token
  const htmlContent = `
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8" />
        <title>Authorizing...</title>
        <script>
          // This script passes the token back to the CMS
          const token = "${tokenData.access_token}";
          window.opener.postMessage(
            "authorization:github:success:" + JSON.stringify({
              provider: "github",
              token: token
            }),
            "*"
          );
          window.close();
        </script>
      </head>
      <body>
        <h1>Authorizing, please wait...</h1>
      </body>
    </html>
  `;
  
  return new Response(htmlContent, {
    headers: { "Content-Type": "text/html" }
  });
}