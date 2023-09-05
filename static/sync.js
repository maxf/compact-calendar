export async function sendEventsToTheApi(events, timestamp) {
  console.log('sending events to the api at', timestamp)
  await fetch('/api/events/', {
    method: 'POST',
    mode: "cors", // no-cors, *cors, same-origin
    cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
    credentials: "same-origin", // include, *same-origin, omit
    headers: {
      "Content-Type": "application/json",
    },
    redirect: "follow", // manual, *follow, error
    referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
    body: JSON.stringify(events)
  });

  await fetch('/api/lastsync/', {
    method: 'POST',
    mode: "cors", // no-cors, *cors, same-origin
    cache: "no-cache", // *default, no-cache, reload, force-cache, only-if-cached
    credentials: "same-origin", // include, *same-origin, omit
    headers: {
      "Content-Type": "application/json",
    },
    redirect: "follow", // manual, *follow, error
    referrerPolicy: "no-referrer", // no-referrer, *no-referrer-when-downgrade, origin, origin-when-cross-origin, same-origin, strict-origin, strict-origin-when-cross-origin, unsafe-url
    body: JSON.stringify({timestamp})
  });
}

export async function findEvents() {
  // check last time localstorage was updated
  const lastLocalSync = parseInt(localStorage.getItem('lastSync'), 10);

  const lastSyncResponse = await fetch('/api/lastsync/');
  console.log('last sync timestamp from localStorage', lastLocalSync);
  const lastRemoteSync = parseInt(await lastSyncResponse.json(), 10);
  console.log('last sync timestamp from API', lastRemoteSync);

  if (lastLocalSync > lastRemoteSync) {
    // use localStorage as it's more recent
    console.log("using local storage as it's more recent");
    var storedData = localStorage.getItem('events');
    if (storedData.length > 0) {
      var events = JSON.parse(storedData);
    } else {
      var events = []
    }
    console.log('events from storage', events);
    // update the Api with the more recent events
    console.log('sending to the API')
    sendEventsToTheApi(events, Date.now());
  } else {
    console.log("using the API as it's more recent");
    var response = await fetch('/api/events/');
    var events = await response.json();
    console.log('events from the API', events);
    console.log('updating storage');
    // update localStorage with the more recent events
    localStorage.setItem('events', JSON.stringify(events));
    localStorage.setItem('lastSync', Date.now());
  }

  return events;
}
