const app = document.getElementById('app');

// Create title and timer elements
const title = document.createElement('h1');
const timer = document.createElement('div');
timer.id = 'timer';

app.appendChild(title);
app.appendChild(timer);

let countdown = null;

document.addEventListener('DOMContentLoaded', () => {
  const app = document.getElementById('app');

  // Create title and timer elements once
  const title = document.createElement('h1');
  const timer = document.createElement('div');
  timer.id = 'timer';

  app.appendChild(title);
  app.appendChild(timer);

  let countdown = null;

  window.addEventListener('message', (event) => {
    const data = event.data;

    if (data.type === 'death') {
      // Show overlay with fade-in
      app.classList.add('active');

      // Clear any previous countdown
      if (countdown) {
        clearInterval(countdown);
        countdown = null;
      }

      let timeLeft = data.time || data.timer || 30;

      title.textContent = 'You have died in combat.';
      timer.textContent = `You may respawn in: ${timeLeft}`;

      countdown = setInterval(() => {
        timeLeft--;

        if (timeLeft > 0) {
          timer.textContent = `You may respawn in: ${timeLeft}`;
        } else {
          timer.textContent = 'You may now respawn.';
          clearInterval(countdown);
          countdown = null;

          fetch(`https://${GetParentResourceName()}/canRespawn`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({
                allowRespawn: true
            })
          })
        }
      }, 1000);
    }

    if (data.type === 'hide') {
      // Fade out overlay
      app.classList.remove('active');

      // Clear text and timer
      title.textContent = '';
      timer.textContent = '';

      if (countdown) {
        clearInterval(countdown);
        countdown = null;
      }
    }
  });
});
