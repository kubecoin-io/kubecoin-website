// Improved GitHub OAuth callback handler for Decap CMS
export async function onRequest(context) {
  const { request, env } = context;
  const url = new URL(request.url);
  const code = url.searchParams.get("code");
  const state = url.searchParams.get("state");

  try {
    // Exchange code for token
    const response = await fetch("https://github.com/login/oauth/access_token", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
      },
      body: JSON.stringify({
        client_id: env.GITHUB_CLIENT_ID,
        client_secret: env.GITHUB_CLIENT_SECRET,
        code,
      }),
    });

    const data = await response.json();
    
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
          <p id="message">This window will close automatically in a few seconds...</p>
          <button id="manual-close" class="button">Return to CMS</button>
        </div>
        
        <script>
          // Store token in localStorage
          const authData = ${JSON.stringify(data)};
          const authState = "${state}";
          
          // Try to notify the opener window (CMS popup flow)
          try {
            if (window.opener) {
              console.log("Authentication successful, notifying opener");
              window.opener.postMessage(
                {
                  type: "oauth",
                  provider: "github",
                  token: authData.access_token,
                  state: authState
                }, 
                document.location.origin
              );
              
              // Close this popup after a short delay
              setTimeout(() => {
                window.close();
              }, 1500);
            } else {
              // No opener, user probably navigated directly
              console.log("No opener window found, setting up for redirect");
              document.getElementById("message").textContent = "Click the button below to return to the CMS.";
              
              // Store token in localStorage for the main window to find
              try {
                localStorage.setItem("netlifyCmsGithubToken", authData.access_token);
                localStorage.setItem("netlifyCmsGithubState", authState);
              } catch (err) {
                console.error("Failed to store authentication data:", err);
              }
            }
          } catch (err) {
            console.error("Error in authentication flow:", err);
          }
          
          // Add manual return button handler
          document.getElementById("manual-close").addEventListener("click", function() {
            window.location.href = "/admin/";
          });
          
          // Redirect back to the admin page after 5 seconds if not closed
          setTimeout(() => {
            window.location.href = "/admin/";
          }, 5000);
        </script>
      </body>
      </html>
    `, {
      headers: {
        "Content-Type": "text/html",
      },
    });
  } catch (error) {
    return new Response(`Authentication Error: ${error.message}`, { status: 500 });
  }
}