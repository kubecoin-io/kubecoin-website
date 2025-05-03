// Improved GitHub OAuth callback handler for Decap CMS
export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");

  // *** 1. Add Server-Side Logging: Log incoming request details ***
  console.log(`Callback received: code=${code ? 'present' : 'missing'}, state=${state}`);

  // *** Basic validation ***
  if (!code || !state) {
    console.error("Callback error: Missing code or state parameter.");
    return new Response("Authentication Error: Missing code or state.", { status: 400 });
  }
  if (!env.GITHUB_CLIENT_ID || !env.GITHUB_CLIENT_SECRET) {
    console.error("Callback error: Missing GITHUB_CLIENT_ID or GITHUB_CLIENT_SECRET environment variables.");
    return new Response("Server Configuration Error: Missing GitHub credentials.", { status: 500 });
  }

  try {
    // *** 2. Add Server-Side Logging: Log before fetching token ***
    console.log(`Exchanging code for token with client_id: ${env.GITHUB_CLIENT_ID}`);

    const response = await fetch("https://github.com/login/oauth/access_token", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json", // Request JSON response from GitHub
      },
      body: JSON.stringify({
        client_id: env.GITHUB_CLIENT_ID,
        client_secret: env.GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    // *** 3. Add Server-Side Logging: Log GitHub response status ***
    console.log(`GitHub token exchange response status: ${response.status}`);

    const data = await response.json();

    // *** 4. Add Server-Side Logging: Log the data received from GitHub ***
    // Be cautious logging the full data in production if it contains sensitive info,
    // but for debugging, log keys or presence of token/error.
    console.log(`GitHub token exchange response data keys: ${Object.keys(data).join(', ')}`);
    if (data.error) {
        console.error(`GitHub token exchange error: ${data.error} - ${data.error_description}`);
    } else if (data.access_token) {
        console.log("GitHub token exchange successful.");
    }

    // *** 5. Check for GitHub Error before proceeding ***
    if (data.error || !data.access_token) {
      const errorDescription = data.error_description || "Unknown error during token exchange.";
      console.error(`Callback failed: ${errorDescription}`);
      // Return an error page instead of the success page
      return new Response(`
        <!DOCTYPE html><html><head><title>Authentication Failed</title></head>
        <body><h2>Authentication Failed</h2><p>Could not obtain token from GitHub: ${errorDescription}</p></body></html>`,
        { status: 400, headers: { "Content-Type": "text/html" } }
      );
    }

    // *** If successful, proceed to generate the success HTML with postMessage script ***
    return new Response(`
      <!DOCTYPE html>
      <html>
      <head>
        <title>Authentication Successful</title>
        <style>
          body {
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
            text-align: center;
            background-color: #f0f2f5;
          }
          .card {
            background: white;
            padding: 2rem;
            border-radius: 8px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
            max-width: 500px;
          }
          .success {
            color: #28a745;
            font-size: 1.5rem;
            margin-bottom: 1rem;
          }
          .button {
            background: #0366d6;
            color: white;
            border: none;
            padding: 0.5rem 1rem;
            border-radius: 4px;
            font-size: 1rem;
            cursor: pointer;
            margin-top: 1rem;
          }
          .button:hover {
            background: #0256b9;
          }
        </style>
      </head>
      <body>
        <div class="card">
          <h2 class="success">Authentication Successful</h2>
          <p>You have successfully authenticated with GitHub.</p>
          <p id="message">This window will close automatically...</p>
          <button id="manual-close" class="button">Return to CMS</button>
        </div>

        <script>
          const authData = ${JSON.stringify(data)}; // Contains access_token now
          const authState = "${state}";
          const targetOrigin = window.location.origin; // Define target origin

          // *** Log before attempting postMessage ***
          console.log("Callback script: Attempting to post message.");
          console.log("Callback script: window.opener exists?", !!window.opener);
          console.log("Callback script: Target Origin:", targetOrigin);

          // *** 6. Improve Client-Side Check: Ensure token exists ***
          if (authData && authData.access_token) {
            try {
              if (window.opener) {
                // *** Log inside the if(window.opener) block ***
                console.log("Callback script: window.opener found. Posting message...");
                window.opener.postMessage(
                  {
                    type: "authorization_response", // Use correct type for Decap CMS
                    provider: "github",
                    token: authData.access_token,
                    state: authState
                  },
                  targetOrigin // Use the defined target origin
                );
                console.log("Callback script: Message posted."); // Log after posting

                setTimeout(() => { window.close(); }, 1500);
              } else {
                // *** Log if no opener found ***
                console.warn("Callback script: No opener window found. Cannot post message.");
                document.getElementById("message").textContent = "Click the button below to return to the CMS.";
                try {
                  // Use standard keys if possible, or custom ones
                  localStorage.setItem("gh-token", authData.access_token);
                  localStorage.setItem("gh-state", authState);
                } catch (err) { console.error("Failed to store auth data:", err); }
              }
            } catch (err) {
              console.error("Callback script: Error during postMessage or closing window:", err);
              document.getElementById("message").textContent = "Error notifying CMS. Please close this window manually.";
            }
          } else {
            // Handle case where token is missing even after server-side check (shouldn't happen often)
            console.error("Callback script (Client-side): access_token missing in authData.");
            document.getElementById("message").textContent = "Authentication failed: Token not found.";
          }

          // Manual close/return logic
          document.getElementById("manual-close").addEventListener("click", function() {
            if (window.opener) { window.close(); }
            else { window.location.href = "/admin/"; } // Redirect if no opener
          });

          // Optional: Redirect back if window doesn't close
          // setTimeout(() => { if (!window.opener) { window.location.href = "/admin/"; } }, 5000);

        </script>
      </body>
      </html>
    `, {
      headers: { "Content-Type": "text/html" },
    });

  } catch (error) {
    // *** 7. Add Server-Side Logging: Log any unexpected fetch/processing errors ***
    console.error(`Unexpected error in callback handler: ${error.message}`, error);
    return new Response(`Authentication Error: ${error.message}`, { status: 500 });
  }
}