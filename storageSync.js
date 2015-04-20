const backendUrl = 'http://localhost:8080';

export default class StorageSync {

  constructor(intervalInSeconds) {
    this.timer = window.setInterval(StorageSync.sync, intervalInSeconds * 1000);
  }

  pullFromServer(callback) {
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
      StorageSync.stopSync();
      callback(false);
    });
  }

  static stopSync() {
    window.clearInterval(this.timer);
  }

  static sync() {
    StorageSync.pushToServer();
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
            StorageSync.stopSync();
            console.log("error: ", error);
          });
        })
        .fail((a,b) => {
          StorageSync.stopSync();
          console.log("error clearing server storage", b);
        });
      }
    }
}
