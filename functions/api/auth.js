// This is the main authentication endpoint that initiates the GitHub OAuth flow
export async function onRequest(context) {
  const clientId = context.env.GITHUB_CLIENT_ID;
  
  // Get the full URL of the current request
  const currentUrl = new URL(context.request.url);
  
  // Construct the callback URL (must be an absolute URL)
  const redirectUrl = new URL("/api/callback", currentUrl.origin);
  
  // Construct the GitHub OAuth URL
  const githubAuthUrl = new URL("https://github.com/login/oauth/authorize");
  githubAuthUrl.searchParams.set("client_id", clientId);
  githubAuthUrl.searchParams.set("redirect_uri", redirectUrl.toString());
  githubAuthUrl.searchParams.set("scope", "repo,user");
  
  // Generate a random state for security
  const state = crypto.randomUUID();
  
  // Store state in a cookie for validation in the callback
  const stateCookie = `gh-state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=300`;
  
  // Add state to GitHub URL
  githubAuthUrl.searchParams.set("state", state);
  
  // Log for debugging (will appear in Cloudflare logs)
  console.log(`Redirecting to GitHub: ${githubAuthUrl.toString()}`);
  console.log(`Callback URL: ${redirectUrl.toString()}`);
  
  // Redirect to GitHub for authentication
  return new Response(null, {
    status: 302,
    headers: {
      "Location": githubAuthUrl.toString(),
      "Set-Cookie": stateCookie
    }
  });
}