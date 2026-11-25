// The contact address shown on the contact page. It forwards to Claire's inbox.
// Shoot requests come in by email; there is no form.
const CONTACT_EMAIL = "hello@claire-tian.com";

const mail = document.getElementById('mail');
if (mail) { mail.href = 'mailto:' + CONTACT_EMAIL; mail.textContent = CONTACT_EMAIL; }
