// This is the main authentication endpoint that initiates the GitHub OAuth flow
export async function onRequest(context) {
  const clientId = context.env.GITHUB_CLIENT_ID;
  
  // Redirect URL back to our site after GitHub authentication
  const redirectUrl = new URL("/api/callback", context.request.url);
  
  // Construct the GitHub OAuth URL
  const githubAuthUrl = new URL("https://github.com/login/oauth/authorize");
  githubAuthUrl.searchParams.set("client_id", clientId);
  githubAuthUrl.searchParams.set("redirect_uri", redirectUrl.toString());
  githubAuthUrl.searchParams.set("scope", "repo,user");
  githubAuthUrl.searchParams.set("state", crypto.randomUUID());
  
  // Redirect the user to GitHub for authentication
  return Response.redirect(githubAuthUrl.toString(), 302);
}