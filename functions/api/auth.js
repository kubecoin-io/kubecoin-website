// Simple GitHub OAuth handler for Netlify CMS
export async function onRequest(context) {
  const clientId = context.env.GITHUB_CLIENT_ID;
  
  if (!clientId) {
    return new Response("GitHub Client ID not configured", { status: 500 });
  }
  
  // Get the full URL of the current request
  const requestUrl = new URL(context.request.url);
  const host = requestUrl.origin;
  
  // Construct callback URL
  const callbackUrl = `${host}/api/callback`;
  
  // Construct GitHub OAuth URL
  const githubUrl = new URL("https://github.com/login/oauth/authorize");
  githubUrl.searchParams.set("client_id", clientId);
  githubUrl.searchParams.set("redirect_uri", callbackUrl);
  githubUrl.searchParams.set("scope", "repo,user");
  
  // Add random state parameter for CSRF protection
  const state = crypto.randomUUID();
  githubUrl.searchParams.set("state", state);
  
  // Set state cookie for verification in callback
  const stateCookie = `gh-state=${state}; Path=/; HttpOnly; Secure; SameSite=Lax; Max-Age=300`;
  
  // Log for debugging
  console.log(`Redirecting to GitHub: ${githubUrl.toString()}`);
  console.log(`Callback URL: ${callbackUrl}`);
  
  // Redirect to GitHub
  return new Response(null, {
    status: 302,
    headers: {
      "Location": githubUrl.toString(),
      "Set-Cookie": stateCookie
    }
  });
}