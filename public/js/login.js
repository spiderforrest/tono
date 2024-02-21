
const submitBtn = document.querySelector('#submit')


submitBtn.addEventListener('click', () => {
  fetch('/api/login', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      username: document.querySelector('#username').value,
      password: document.querySelector('#password').value
    })
    // go home
  }).then((response) => {
      if (response.status == 200) {
        document.location.replace('/');
      }
  });
});
