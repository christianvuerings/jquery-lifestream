// AngularJS: Avoid redirection loop in legacy browser (IE) with HTML5 mode
// https://gist.github.com/3834721
if (!history.pushState) {
  if (window.location.hash) {
    //Hash and a path, just keep the hash (redirect)
    if (window.location.pathname !== '/') {
      window.location.replace('/#!' + window.location.hash.substr(2));
    }
  } else {
    //No hash, take path
    window.location.replace('/#!' + window.location.pathname);
  }
}
