// GitHub OAuth callback handler for Netlify CMS
export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  
  // Get the stored state cookie
  const cookies = request.headers.get("Cookie") || "";
  const cookieState = cookies.split("; ")
    .find(cookie => cookie.startsWith("gh-state="))
    ?.split("=")[1];
  
  if (!code) {
    return new Response("No code received from GitHub", { status: 400 });
  }
  
  // Validate state if present
  if (cookieState && state !== cookieState) {
    console.error("State mismatch - CSRF attack possible");
    return new Response("Invalid state parameter", { status: 403 });
  }
  
  try {
    // Exchange code for access token
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
    
    if (!tokenResponse.ok) {
      throw new Error(`GitHub token request failed: ${tokenResponse.status}`);
    }
    
    const tokenData = await tokenResponse.json();
    
    if (tokenData.error) {
      throw new Error(`GitHub error: ${tokenData.error_description || tokenData.error}`);
    }
    
    // Create HTML with script to pass token back to opener window (Netlify CMS)
    const htmlResponse = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Authenticating...</title>
          <script>
            (function() {
              function receiveMessage(e) {
                console.log("receiveMessage %o", e);
                // verify origin
                window.opener.postMessage(
                  'authorization:github:success:${JSON.stringify({
                    provider: "github",
                    token: tokenData.access_token
                  })}',
                  e.origin
                );
              }
              window.addEventListener("message", receiveMessage, false);
              
              // Start handshake with parent
              console.log("Sending message to opener");
              window.opener.postMessage("ready", "*");
            })();
          </script>
        </head>
        <body>
          <h1>Authenticating with GitHub...</h1>
          <p>This window should close automatically. If it doesn't, you can close it manually.</p>
        </body>
      </html>
    `;
    
    // Clear the state cookie
    const clearStateCookie = "gh-state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0";
    
    return new Response(htmlResponse, {
      headers: {
        "Content-Type": "text/html",
        "Set-Cookie": clearStateCookie
      }
    });
    
  } catch (error) {
    console.error("Authentication error:", error);
    
    return new Response(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Authentication Error</title>
          <script>
            console.error("Authentication error:", ${JSON.stringify(error.message)});
            window.opener && window.opener.postMessage(
              'authorization:github:error:${JSON.stringify({ error: error.message })}',
              "*"
            );
          </script>
        </head>
        <body>
          <h1>Authentication Error</h1>
          <p>${error.message}</p>
          <p>Please close this window and try again.</p>
        </body>
      </html>
    `, {
      status: 400,
      headers: { "Content-Type": "text/html" }
    });
  }
}