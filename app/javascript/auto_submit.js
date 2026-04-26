document.addEventListener("change", function (event) {
  const form = event.target.closest("form[data-auto-submit]");
  if (form) form.requestSubmit();
});
