// Improved GitHub OAuth callback handler for Decap CMS
export async function onRequest(context) {
  const { request, env } = context;
  
  // Get code and state parameters from the request URL
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");
  
  console.log("Received callback with code:", code ? "present" : "missing");
  console.log("Received state:", state);
  
  // Get state from cookies for validation
  const cookies = request.headers.get("Cookie") || "";
  const cookieState = cookies.split("; ")
    .find(cookie => cookie.startsWith("gh-state="))
    ?.split("=")[1];
  
  console.log("Cookie state:", cookieState);
  
  // Check if code is present
  if (!code) {
    return new Response(`
      <!DOCTYPE html>
      <html>
        <head><title>Authentication Error</title></head>
        <body>
          <h1>Authentication Error</h1>
          <p>No code was received from GitHub. Please try again.</p>
          <script>
            window.opener && window.opener.postMessage(
              'authorization:github:error:{"error":"No code received"}',
              "*"
            );
          </script>
        </body>
      </html>
    `, { 
      status: 400,
      headers: { "Content-Type": "text/html" }
    });
  }
  
  try {
    // Exchange code for access token
    console.log("Exchanging code for token...");
    const tokenUrl = "https://github.com/login/oauth/access_token";
    const tokenResponse = await fetch(tokenUrl, {
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
    
    // Get the token response as JSON
    const tokenData = await tokenResponse.json();
    console.log("Token response status:", tokenResponse.status);
    
    // Check for errors
    if (tokenData.error) {
      console.error("GitHub OAuth error:", tokenData.error);
      throw new Error(tokenData.error_description || tokenData.error);
    }
    
    // Log success
    console.log("Successfully obtained access token");
    
    // Prepare the success response with the token
    const htmlResponse = `
      <!DOCTYPE html>
      <html>
        <head>
          <title>Authentication Successful</title>
          <script>
            (function() {
              const token = "${tokenData.access_token}";
              
              console.log("Authentication successful, notifying opener");
              
              // Post message to the opener window with the token
              // The format is specifically what Decap CMS expects
              window.opener.postMessage(
                'authorization:github:success:{"token":"' + token + '","provider":"github"}',
                "*"
              );
              
              // Close the popup window after a short delay
              setTimeout(function() {
                window.close();
              }, 250);
            })();
          </script>
        </head>
        <body>
          <h1>Authentication Successful</h1>
          <p>You have successfully authenticated with GitHub. This window will close automatically.</p>
        </body>
      </html>
    `;
    
    // Clear the state cookie
    const clearStateCookie = "gh-state=; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=0";
    
    // Return the HTML page with the success message
    return new Response(htmlResponse, {
      headers: {
        "Content-Type": "text/html",
        "Set-Cookie": clearStateCookie,
        "Cache-Control": "no-store"
      }
    });
    
  } catch (error) {
    console.error("Authentication error:", error.message);
    
    // Return an error page
    return new Response(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Authentication Error</title>
          <script>
            console.error("Authentication error:", ${JSON.stringify(error.message)});
            window.opener && window.opener.postMessage(
              'authorization:github:error:{"error":${JSON.stringify(error.message)}}',
              "*"
            );
            
            setTimeout(function() {
              window.close();
            }, 5000);
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
      headers: { "Content-Type": "text/html", "Cache-Control": "no-store" }
    });
  }
}

// Decap CMS initialization page
export const decapCMSPage = `
<!DOCTYPE html>
<html>
  <head>
    <meta charset="UTF-8" />
    <title>Decap CMS</title>
    <!-- Remove any extra scripts/styles to ensure Decap is the only controller -->
    <!-- e.g. NO netlify identity, NO loading spinners, etc. -->
    <script>
      // We still need manual init to avoid DOM conflicts
      window.CMS_MANUAL_INIT = true;
    </script>
  </head>
  <body>
    <!-- Single mount point for Decap CMS, no extra overlays/containers -->
    <div id="nc-root"></div>

    <!-- Load Decap CMS at latest version -->
    <script src="https://unpkg.com/decap-cms@latest/dist/decap-cms.js"></script>

    <script>
      document.addEventListener('DOMContentLoaded', () => {
        CMS.init({
          config: {
            load_config_file: false,
            backend: {
              name: 'github',
              repo: 'kubecoin-io/kubecoin-website',
              branch: 'main',
              auth_endpoint: 'api/auth'
            },
            media_folder: 'content/images',
            public_folder: '/images'
          }
        });
      });
    </script>
  </body>
</html>
`;