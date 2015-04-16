const backendUrl = 'http://localhost:8080';

export default class StorageSync {

  constructor(intervalInSeconds) {
    StorageSync.sync();
    window.setInterval(StorageSync.sync, intervalInSeconds * 1000);
  }

  static sync() {
    StorageSync.pushToServer();
  }

  static pushToServer() {

    $.post(backendUrl + '/documents/clear/',
      (data) => {
        $.post(backendUrl + '/documents/',
          localStorage,
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
};
