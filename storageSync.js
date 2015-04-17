const backendUrl = 'http://localhost:8080';

export default class StorageSync {

  constructor() {
//    this.pullFromServer();
//    window.setInterval(StorageSync.sync, intervalInSeconds * 1000);
  }

  pullFromServer(successCallback, errorCallback) {
    $.get(backendUrl + '/documents/',
      (data, status) => {
        console.log('got docs', data);
        window.localStorage.clear();
        for (let key in data) {
          if (data.hasOwnProperty(key)) {
            window.localStorage.setItem(key, data[key]);
          }
        }
        successCallback();
      }
    )
    .fail(() => {
      console.log('error pulling from server');
      errorCallback();
    });
  }

  static sync() {
    StorageSync.pushToServer();
  }

  static pushToServer() {
    $.post(backendUrl + '/documents/clear/',
      (data) => {
        $.post(backendUrl + '/documents/',
          window.localStorage,
          (data) => {
            console.log("data saved to server");
          })
        .fail((error) => {
          console.log("error: ", error);
        });
      })
      .fail((a,b) => {
        console.log("error clearing server storage", b);
      });
  }
}
