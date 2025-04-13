// Improved GitHub OAuth handler for Decap CMS
export async function onRequest(context) {
  const { request, env } = context;
  
  // Get GitHub client ID from environment variables
  const clientId = env.GITHUB_CLIENT_ID;
  
  if (!clientId) {
    return new Response("GitHub Client ID not configured. Please add GITHUB_CLIENT_ID to your environment variables.", 
      { status: 500, headers: { "Content-Type": "text/html" } });
  }
  
  // Get current URL and origin for building callback URL
  const currentUrl = new URL(request.url);
  const origin = currentUrl.origin;
  
  // Verify we're getting correct origin
  console.log("Origin for OAuth redirect:", origin);
  
  // Build the callback URL - must be an absolute URL
  const callbackUrl = `${origin}/api/callback`;
  console.log("Callback URL:", callbackUrl);
  
  // Generate a state parameter for CSRF protection
  const state = crypto.randomUUID();
  
  // Create the cookie with the state (important for security)
  const stateCookie = `gh-state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=300`;
  
  // Build GitHub authorization URL with correct parameters
  const githubUrl = new URL("https://github.com/login/oauth/authorize");
  githubUrl.searchParams.set("client_id", clientId);
  githubUrl.searchParams.set("redirect_uri", callbackUrl);
  githubUrl.searchParams.set("scope", "repo,user");
  githubUrl.searchParams.set("state", state);
  
  console.log("Redirecting to GitHub URL:", githubUrl.toString());
  
  // Return response that redirects to GitHub with proper cookie
  return new Response("Redirecting to GitHub...", {
    status: 302,
    headers: {
      "Location": githubUrl.toString(),
      "Set-Cookie": stateCookie,
      "Cache-Control": "no-store"
    }
  });
}