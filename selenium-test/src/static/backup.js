let eventSource = null;

function connectSSE() {
  const statusElement = document.getElementById('connectionStatus');
  if (eventSource) {
    eventSource.close();
  }
  eventSource = new EventSource('/metrics-stream');
  eventSource.onopen = function() {
    statusElement.textContent = 'Connected';
    statusElement.className = 'connection-status connected';
    console.log('SSE Connected');
  };
  eventSource.onmessage = function(event) {
    try {
      const data = JSON.parse(event.data);
      updateServerMetrics(data.servers);
    } catch (error) {
      console.error('Error parsing metrics:', error);
    }
  };
  eventSource.onerror = function(error) {
    statusElement.textContent = 'Disconnected - Reconnecting...';
    statusElement.className = 'connection-status disconnected';
    console.error('SSE Error:', error);
    setTimeout(connectSSE, 5000);
  };
}

async function updateSessionLink() {
  const sessionLink = document.querySelector("#viewSessionButton");

  try {
    sessionLink.textContent = "Loading...";
    sessionLink.disabled = true;

    const response = await fetch("http://localhost:8888/selenium-hub-ip");
    const data = await response.json();
    const serverIp = data.ip;

    sessionLink.disabled = false;
    sessionLink.textContent = "View Session";
    sessionLink.addEventListener("click", (event) => {
      event.preventDefault();
      window.open(`http://${serverIp}:4444/ui/#/sessions`, "_blank");
    });
  } catch (error) {
    console.error("Failed to fetch server IP:", error);
    sessionLink.textContent = "Error: Retry";
    sessionLink.disabled = false;
  }
}

window.onload = updateSessionLink;

// function updateServerMetrics(servers) {
//   const container = document.getElementById('server-container');
//   container.innerHTML = '';
//   servers.forEach(server => {
//     const row = document.createElement('div');
//     row.className = 'server-row';
//     row.innerHTML = `
    
        
//         <div>${server.hostname}</div>
//         <div>${server.ip || 'N/A'}</div>
//         <div>${server.cpu}</div>
//         <div>${server.ram}</div>`;
//     container.appendChild(row);
//   });
// }

document.getElementById('startTestButton').addEventListener('click', function() {
  const proxy = document.getElementById('proxy').value;
  const org = document.getElementById('org').value;
  const url = document.getElementById('pac_url').value;
  const user = document.getElementById('k_username').value;
  const password = document.getElementById('k_password').value;
  const sessions = document.getElementById('sessions').value;
  const scenario = document.getElementById('scenario').value;
  const responseContainer = document.getElementById('loadTestResponse');
  const mode = scenario === '1' ? 'conc' : 'seq';
  responseContainer.innerHTML = '<p>Test is starting... </p>';
  fetch('/start-load-test', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      proxy: proxy,
      org: org,
      url: url,
      username: user,
      password: password,
      sessions: parseInt(sessions),
      mode: mode,
    }),
  }).then((response) => response.json()).then((data) => {
    responseContainer.innerHTML += `
        
        <p>${data.message || 'Test completed successfully!'}</p>`;
    const viewReportButton = document.createElement('a');
    viewReportButton.href = '/latest-report';
    viewReportButton.className = 'button button-black';
    viewReportButton.textContent = 'Download Report';
    viewReportButton.target = '_blank';
    responseContainer.appendChild(viewReportButton);
  }).catch((error) => {
    console.error('Error:', error);
    responseContainer.innerHTML = `
        
        <p style="color: red">Error: ${error.message}</p>`;
  });
});

document.getElementById('stopTestButton').addEventListener('click', function() {
  const responseContainer = document.getElementById('loadTestResponse');
  responseContainer.innerHTML = '<p>Start the process of clearing all user sessions... </p>';
  fetch('/stop-test', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      action: 'stop'
    }),
  }).then((response) => response.json()).then((data) => {
    responseContainer.innerHTML += `
        
        <p>${data.message || 'Completed clearing all user sessions!'}</p>`;
  }).catch((error) => {
    console.error('Error:', error);
    responseContainer.innerHTML = `
        
        <p style="color: red">Error: ${error.message}</p>`;
  });
});

connectSSE();
window.addEventListener('beforeunload', () => {
  if (eventSource) {
    eventSource.close();
  }
});
