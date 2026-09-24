// CloudFront viewer-request function:
//  1. www.leonardgrazian.com -> leonardgrazian.com (301)
//  2. /resume and /resume/ -> /resume/index.html (S3 REST origins don't resolve directory indexes)
function handler(event) {
  var request = event.request;
  var host = request.headers.host && request.headers.host.value;

  if (host && host.indexOf("www.") === 0) {
    var qs = Object.keys(request.querystring)
      .map(function (k) {
        var v = request.querystring[k];
        return v.value ? k + "=" + v.value : k;
      })
      .join("&");
    return {
      statusCode: 301,
      statusDescription: "Moved Permanently",
      headers: {
        location: { value: "https://" + host.slice(4) + request.uri + (qs ? "?" + qs : "") },
      },
    };
  }

  var uri = request.uri;
  if (uri.endsWith("/")) {
    request.uri = uri + "index.html";
  } else if (uri.split("/").pop().indexOf(".") === -1) {
    request.uri = uri + "/index.html";
  }
  return request;
}
