export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  
  // Get the state cookie for validation
  const cookies = request.headers.get("Cookie") || "";
  const cookieState = cookies.split("; ")
    .find(cookie => cookie.startsWith("gh-state="))
    ?.split("=")[1];
  
  // Check if code is present
  if (!code) {
    return new Response("Error: No code provided by GitHub", { 
      status: 400,
      headers: { "Content-Type": "text/html" }
    });
  }
  
  // Validate state if present (CSRF protection)
  if (cookieState && state !== cookieState) {
    console.error("State mismatch - potential CSRF attack");
    return new Response("Error: State validation failed", { 
      status: 403,
      headers: { "Content-Type": "text/html" }
    });
  }
  
  try {
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
    
    if (!tokenResponse.ok) {
      throw new Error(`GitHub token exchange failed: ${tokenResponse.status}`);
    }
    
    const tokenData = await tokenResponse.json();
    
    if (tokenData.error) {
      throw new Error(`GitHub error: ${tokenData.error_description || tokenData.error}`);
    }
    
    // Important: The format of this message MUST match exactly what Decap CMS expects
    const htmlContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <title>Authorization Complete</title>
          <script>
            (function() {
              // The token format required by Decap CMS
              const token = "${tokenData.access_token}";
              
              // Post the message in the specific format Decap CMS expects
              window.opener.postMessage(
                'authorization:github:success:{"token":"' + token + '","provider":"github"}',
                "*"
              );
              
              // Close the popup after passing the token
              setTimeout(function() {
                window.close();
              }, 100);
            })();
          </script>
        </head>
        <body>
          <h1>Authorization Successful</h1>
          <p>This window will close automatically. If it doesn't, you can close it manually.</p>
        </body>
      </html>
    `;
    
    // Clear the state cookie
    const clearStateCookie = "gh-state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0";
    
    // Return the HTML page with the authentication script
    return new Response(htmlContent, {
      headers: { 
        "Content-Type": "text/html",
        "Set-Cookie": clearStateCookie
      }
    });
    
  } catch (error) {
    console.error("Authentication error:", error);
    
    // Return an error page that also closes the popup
    return new Response(`
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8" />
          <title>Authentication Error</title>
          <script>
            window.opener.postMessage(
              'authorization:github:error:${JSON.stringify({ error: error.message })}',
              "*"
            );
            setTimeout(function() {
              window.close();
            }, 1500);
          </script>
        </head>
        <body>
          <h1>Authentication Error</h1>
          <p>${error.message}</p>
          <p>This window will close automatically.</p>
        </body>
      </html>
    `, {
      status: 400,
      headers: { "Content-Type": "text/html" }
    });
  }
}