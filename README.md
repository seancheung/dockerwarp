# WARP

Cloudflare warp client in docker

## Usage

### CLI

```bash
docker run --name warp -d -v /path/to/data:/var/lib/cloudflare-warp -p 10800:1080 --restart unless-stopped seancheung/warp:latest
```

### Compose

```yaml
---
services:
  warp:
    image: seancheung/warp:latest
    pull_policy: always
    container_name: warp
    volumes:
      - /path/to/data:/var/lib/cloudflare-warp
    ports:
      - "10800:1080"
    restart: unless-stopped
```

### Additional Settings

- Set warp+ license key with env `WARP_LICENSE_KEY`.
- Change warp local proxy port with env `WARP_PROXY_PORT`.
- Pass additional gost arguments with docker `command` (Do not change the listening port as its used by healthcheck).

### Zero Trust

By using [manual deployment](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/mdm-deployment/), you can initialize the zero trust registration non-interactively. You will need to do the following in [Dashboard](https://one.dash.cloudflare.com/):

- Go to **Access > Service Auth**. Create a [service token](https://developers.cloudflare.com/cloudflare-one/identity/service-tokens/#create-a-service-token).
- Go to **Settings > WARP Client > Device settings**. Create a policy configured with an expression that is set to `User Email is non_identity@<team>.cloudflareaccess.com` (You can check the email address in **My Team > Devices**), and then set its service mode to `Proxy mode`.
- (Optional) Go to **Settings > WARP Client > Device enrollment**. Set [enroll permission](https://developers.cloudflare.com/cloudflare-one/connections/connect-devices/warp/deployment/device-enrollment/#check-for-service-token) for the client.

Write your organization name and service token into */var/lib/cloudflare-warp/mdm.xml*.

```xml
<dict>
  <key>organization</key>
  <string>__ORG__</string>
  <key>auth_client_id</key>
  <string>__ID__</string>
  <key>auth_client_secret</key>
  <string>__SECRET__</string>
</dict>
```

You may optionally set `override_warp_endpoint` if the default endpoint is blocked (in China). Get alternative endpoints [here](https://sssis.me/warp-box.html).

```xml
<dict>
  <!-- ... -->
  <key>override_warp_endpoint</key>
  <string>__IP:PORT__</string>
</dict>
```

Start the serice. No further actions required.
