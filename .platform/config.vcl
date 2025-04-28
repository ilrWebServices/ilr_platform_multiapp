import vsthrottle;

sub vcl_recv {
    set req.backend_hint = application.backend();

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

    # Throttle all requests to the CAHRS resource library to 1 per second.
    if (req.url ~ "^/cahrs/research-and-insights/resource-library" && vsthrottle.is_denied("/cahrs/research-and-insights/resource-library", 1, 1s)) {
        return (synth(429, "Too Many Requests"));
    }

    # Bypass the cache. We'll enable it later, when we've configured the Purge module for Drupal.
    return (pass);
}
