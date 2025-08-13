import vsthrottle;

sub vcl_recv {
    set req.backend_hint = drupal.backend();

    # The Platform.sh router provides the real client IP as the `X-Client-IP`
    # header. This replaces client.identity in other implementations.
    # If a client has exceeded 10 page requests in 15 seconds, block them for
    # 60 seconds.
    # if (req.url !~ "^[^?]*\.(css|gif|ico|jpeg|jpg|js|pdf|png|svg|ttf|txt|webm|webp|woff|woff2|xml)(\?.*)?$" && vsthrottle.is_denied(req.http.X-Client-IP, 10, 15s, 60s)) {
    #     return (synth(429, "Too Many Requests"));
    # }

    # If a client has exceeded 3 CAHRS resource library requests in 10 seconds,
    # block them for 60 seconds.
    # if (req.url ~ "^/cahrs/research-and-insights/resource-library" && vsthrottle.is_denied(req.http.X-Client-IP, 3, 10s, 60s)) {
    #     return (synth(429, "Too Many Requests"));
    # }

    # Throttle all requests to the CAHRS resource library to 1 every second.
    if (req.url ~ "^/cahrs/research-and-insights/resource-library" && vsthrottle.is_denied("/cahrs/research-and-insights/resource-library", 1, 1s)) {
        return (synth(429, "Too Many Requests"));
    }

    # LEGACY DRUPAL PATHS - The content at these paths is still served from our old Drupal site.

	# Note the trailing slash. Without it, Drupal-latest /sites/default/files-d8 will be included, too.
    if (req.url ~ "^/sites/default/files/") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/modules/node") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/modules/system") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/modules/user") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/sites/all/libraries") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/sites/all/modules") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/sites/all/themes") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/ilr-review") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/nyc-conference-center") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/eform") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/misc") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/mobilizing-against-inequality") {
        set req.backend_hint = legacy_proxy.backend();
    }
    # These are links to archive.ilr.cornell.edu, so should be handled by D7.
    elseif (req.url ~ "^/download/") {
        set req.backend_hint = legacy_proxy.backend();
    }
    elseif (req.url ~ "^/sitemap.xml") {
        set req.backend_hint = legacy_proxy.backend();
    }

    # Bypass the cache. We'll enable it later, when we've configured the Purge module for Drupal.
    return (pass);
}
