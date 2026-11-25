// Where booking requests and the contact link go. Change this one line to the real address.
const CONTACT_EMAIL = "hello@claire-tian.com";

const mail = document.getElementById('mail');
if (mail) { mail.href = 'mailto:' + CONTACT_EMAIL; mail.textContent = CONTACT_EMAIL; }

// The site has no server, so the form opens the visitor's own email app with the request filled in.
// Swap this for a form service or a scheduling embed when real booking is added.
const form = document.getElementById('booking');
if (form) {
  const status = document.getElementById('status');
  const dateInput = form.elements.date;
  const t = new Date();
  dateInput.min = new Date(t.getTime() - t.getTimezoneOffset() * 60000).toISOString().slice(0, 10);
  form.addEventListener('submit', e => {
    e.preventDefault();
    const f = Object.fromEntries(new FormData(form));
    if (f.website) return;                       // filled by bots only
    const missing = ['name', 'email', 'kind', 'date'].filter(k => !String(f[k] || '').trim());
    if (missing.length) { status.textContent = 'please fill in: ' + missing.join(', ') + '.'; form.elements[missing[0]].focus(); return; }
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(f.email)) { status.textContent = 'that email address looks off.'; form.elements.email.focus(); return; }
    if (dateInput.min && f.date < dateInput.min) { status.textContent = 'that date has already passed.'; dateInput.focus(); return; }
    const subject = 'Shoot request: ' + f.kind + ' on ' + f.date;
    const body = ['Name: ' + f.name, 'Email: ' + f.email, 'Shoot: ' + f.kind, 'Date: ' + f.date,
                  'Where: ' + (f.place || 'not sure yet'), '', f.idea || ''].join('\n');
    location.href = 'mailto:' + CONTACT_EMAIL + '?subject=' + encodeURIComponent(subject) + '&body=' + encodeURIComponent(body);
    status.textContent = 'your email app should open with the request ready to send. if nothing opens, write to ' + CONTACT_EMAIL + '.';
  });
}
