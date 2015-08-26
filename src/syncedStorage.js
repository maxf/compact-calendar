/*global $*/

const backendUrl = 'http://localhost:8080';

export default class SyncedStorage {

  constructor(callback) {
    this.pullFromServer((success) => {
      if (success) {
        this.timer = window.setInterval(this.sync.bind(this), 10000);
        this.modified = false;
      }
      callback(success);
    });
  }

  getItem(key) {
    try {
      return JSON.parse(window.localStorage[key]);
    } catch(e) {
      return undefined;
    }
  }

  setItem(key, value) {
    this.modified = true;
    return window.localStorage.setItem(key, value);
  }

  stopSync() {
    window.clearInterval(this.timer);
  }

  sync() {
    if (this.modified) {
      this.pushToServer();
      this.modified = false;
    }
  }

  pullFromServer(callback) {
    $.get(backendUrl + '/documents/',
      (data, status) => {
        for (let key in data) {
          if (data.hasOwnProperty(key)) {
            window.localStorage.setItem(key, data[key]);
          }
        }
        callback(true);
      }
    )
    .fail(() => {
      this.stopSync();
      callback(false);
    });
  }

  pushToServer() {
    if (localStorage.length) {
      $.post(backendUrl + '/documents/clear/',
        (data) => {
          $.post(backendUrl + '/documents/',
            window.localStorage,
            (data) => {
              console.log("data saved to server:", window.localStorage);
            })
          .fail((jxhr, error) => {
            this.stopSync();
            console.log("error: ", error);
          });
        })
        .fail((a,b) => {
          this.stopSync();
          console.log("error clearing server storage", b);
        });
      }
    }
}

