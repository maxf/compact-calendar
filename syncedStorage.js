const backendUrl = 'http://localhost:8080';

export default class SyncedStorage {

  constructor(callback) {
    SyncedStorage.pullFromServer((success) => {
      if (success) {
        this.timer = window.setInterval(SyncedStorage.sync, 10000);
        console.log('timer:',this.timer);
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
    console.log("set");
    this.modified = true;
    return window.localStorage.setItem(key, value);
  }




  // === Static =======================


  static pullFromServer(callback) {
    $.get(backendUrl + '/documents/',
      (data, status) => {
        console.log('got docs', data);
        for (let key in data) {
          if (data.hasOwnProperty(key)) {
            console.log(key, data[key]);
            window.localStorage.setItem(key, data[key]);
          }
        }
        callback(true);
      }
    )
    .fail(() => {
      SyncedStorage.stopSync();
      callback(false);
    });
  }

  static stopSync() {
    window.clearInterval(this.timer);
  }

  static sync() {
    console.log('sync');
    if (this.modified) {
      console.log('yes');
      SyncedStorage.pushToServer();
      this.modified = false;
    } else console.log('no');
  }

  static pushToServer() {
    if (localStorage.length) {
      $.post(backendUrl + '/documents/clear/',
        (data) => {
          $.post(backendUrl + '/documents/',
            window.localStorage,
            (data) => {
              console.log("data saved to server");
            })
          .fail((jxhr, error) => {
            SyncedStorage.stopSync();
            console.log("error: ", error);
          });
        })
        .fail((a,b) => {
          SyncedStorage.stopSync();
          console.log("error clearing server storage", b);
        });
      }
    }
}
