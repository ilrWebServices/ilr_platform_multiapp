# ILR Proxy and Drupal 8 Deployment Repo

This codebase exists solely to combine the Drupal 8 ILR site and the ILR website proxy repositories for hosting on platform.sh.

# Requirements

- `git` 2.10 or higher

# Setup

To clone this repository along with the embedded submodules, use the `--recurse-submodules` argument. For example:

```
$ git clone --recurse-submodules git@github.com:ilrWebServices/ilr_platform_multiapp.git
```

Add a git remote to the Platform.sh project:

```
$ git remote add platform yf4o2w34wqxm6@git.us-2.platform.sh:yf4o2w34wqxm6.git
```

# Updating

To update either of the applications (proxy or D8), run the following:

```
$ git pull origin
$ git submodule update --remote
```

Then run a `git diff --submodules` to see a list of the new commits in each project. You can use that output in your commit message.

Commit the change to the submodule if the diff looks correct.

# Deployment

After updating the project submodules, push the project to the platform remote:

```
git push platform
```

Be sure to push your changes to `origin`, too, via `git push origin`. While not essential, it provides a remote backup of the repository outside of our hosting provider.

# Required platform.sh files

Platform.sh documentation recommends that some files, like `.environment` and scripts, be placed in the root directory of an application. Since our proxy and drupal8 applications are running in this multiapp, we try to avoid hosting-specific configuration in their respective repos.

Instead, we add the required files during the build hooks for the applications. To avoid complicated quote escaping, the files are base64 encoded.

The [Encode Decode extension][] for VS Code is useful for editing these embedded files.

# Troubleshooting

If the site is unresponsive or slow, first check to see if the issue is with the proxy or the target hosts behind it.

To do so, you can visit the target hosts directly to check their performance. The target hosts for production are:

- https://d8-edit.ilr.cornell.edu - As of June 2020, this hosts:
  - `/programs/professional-education`
  - `/work-and-coronavirus`
  - `/news/ilr-news/covid-19`
  - `/blog`
  - `/ilrie`
  - Additional dependent paths such as `/core` and `/libraries/union`.
- https://d7.ilr.cornell.edu - This is the fallback for everything else.

For example, if http://www.ilr.cornell.edu/work-and-coronavirus is affected, visit https://d8-edit.ilr.cornell.edu/work-and-coronavirus to see if the issue is there, too.

If so, the problem is most likely with Drupal, Platform.sh, or its underlying Amazon Web Services.

If the problem only happens on www.ilr.cornell.edu, the proxy is suspect.

## Verify the proxy source of a request

If you're not sure which target is serving the current request, you can examine the response headers to check the `x-ilr-proxy-source` header.

You can either use the _Network_ developer tool in any major browser, or a command line tool like `curl`. For example:

```
$ curl --head https://www.ilr.cornell.edu/people
```

...will return the HTTP headers for the people page. The output will look something like the following, which has been truncated for readability.

```
HTTP/2 200
cache-control: public, max-age=1800
content-language: en
content-type: text/html; charset=utf-8
date: Thu, 04 Jun 2020 16:35:40 GMT
...
x-ilr-proxy-source: <https://d7.ilr.cornell.edu>
...
```

# Monitoring the Proxy

The proxy runs on a process manager and load balancer called [PM2][].

You can get an overview of the PM2 status with the following command:

```
$ platform ssh --app=proxy "node_modules/.bin/pm2 status"
```

To monitor PM2 in real time, use this command:

```
$ platform ssh --app=proxy "node_modules/.bin/pm2 monit"
```

If you see high memory or CPU usage, the proxy may have an issue. Typically, however, CPU usage should be very low and memory usage hovers around 50 MB. Note that PM2 is configured to restart a service if its memory usage rises above 200 MB.

# Uptime Monitoring

We use [Uptime Robot][] to monitor the status of the proxy and the D7 and D8 target hosts. You can see the current status of the sites at:

https://stats.uptimerobot.com/YMXL9T33vX

Email and Slack alerts are configured for all three sites, so we can see if an outage is occurring on the proxy, one of the Drupal sites, or some combination of the three.

The credentials for our Uptime Robot account are stored in the `Shared-ILR passwords` folder in LastPass.


[PM2]: https://pm2.keymetrics.io/
[Encode Decode extension]: https://github.com/mitchdenny/ecdc
[Uptime Robot]: https://uptimerobot.com/
