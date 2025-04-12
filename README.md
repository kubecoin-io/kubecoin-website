# Kubecoin.io Website

## Project Setup

This project is a static site built with Pelican, using the Papyrus theme and Decap CMS for content management. It is deployed on Cloudflare Pages.

### Environment Variables

To enable GitHub OAuth for Decap CMS, set the following environment variables in your Cloudflare Pages project:

- `GITHUB_CLIENT_ID`: Your GitHub OAuth application's client ID.
- `GITHUB_CLIENT_SECRET`: Your GitHub OAuth application's client secret.

### Configuring Cloudflare Access for Google Login

To protect the Kubernetes dashboard with Google login:

1. Go to your Cloudflare dashboard and navigate to **Access** > **Applications**.
2. Create a new application and set the **Application Domain** to the URL of your protected resource (e.g., `/dashboard/`).
3. Under **Identity Providers**, ensure Google is enabled.
4. Save the application and note the login URL.

### Build and Deployment

- **Build Command**: `pelican content`
- **Output Directory**: `output`

### Local Development

1. Install dependencies:
   ```bash
   pip install pelican bs4
   ```
2. Run the development server:
   ```bash
   pelican --listen
   ```

### Content Management

Access Decap CMS at `/admin` to manage posts and pages.