// Where "send" on the contact page addresses the email. It forwards to Claire's inbox.
// The address is not shown on the page.
const CONTACT_EMAIL = "hello@claire-tian.com";

// "i have an idea": one text box. The site has no server, so sending opens the visitor's own
// email app with the idea filled in.
const form = document.getElementById('idea');
if (form) form.addEventListener('submit', e => {
  e.preventDefault();
  const status = document.getElementById('status');
  const idea = form.elements.idea.value.trim();
  if (!idea) { status.textContent = 'nothing written.'; form.elements.idea.focus(); return; }
  location.href = 'mailto:' + CONTACT_EMAIL + '?subject=' + encodeURIComponent('i have an idea') + '&body=' + encodeURIComponent(idea);
  status.textContent = 'your email app should open. if it does not, write to ' + CONTACT_EMAIL + '.';
});
