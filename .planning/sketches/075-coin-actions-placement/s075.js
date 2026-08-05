// Toggle bar: each button writes one data-* attribute on <html>, CSS does the rest.
// Kept in its own file so `node --check` can see it - an inline <script> with a
// syntax error renders a page that looks fine and ignores every click.
document.querySelectorAll('.bar button').forEach(function (b) {
  b.addEventListener('click', function () {
    var key = b.dataset.k;
    document.documentElement.setAttribute('data-' + key, b.dataset.val);
    document.querySelectorAll('.bar button[data-k="' + key + '"]').forEach(function (o) {
      o.classList.toggle('on', o === b);
    });
  });
});
