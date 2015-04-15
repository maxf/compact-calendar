const backendUrl = 'http://localhost:8080';

export default class StorageSync {

  constructor(intervalInSeconds) {
    StorageSync.sync();
//    window.setInterval(StorageSync.sync, intervalInSeconds * 1000);
  }


  static sync() {
    var key, val;
    for (let i=0; i<localStorage.length; i++) {
      // start simple and send all to the server
      key = localStorage.key(i);
      val = localStorage[key];
      console.log(key, val);
    }

  }

//  loadLocalStorageFromServer() {
//    console.log("loading from server", this.markedDays);
//    $.get(backendUrl + '/get',
//      (data) => {
//        console.log('data',data);
//        try {
//          let dataObj = JSON.parse(data);
//          this.markedDays = dataObj.markedDays;
//          this.weekNotes = dataObj.weekNotes;
//        } catch (err) {
//          return false;
//        }
//        return true;
//      }
//      );
//  }
//
//

  static pushToServer(key, valObj) {
    $.post(backendUrl + '/post',
      {calendarData: JSON.stringify({markedDays: this.markedDays, weekNotes: this.weekNotes})},
      (data) => {
        console.log("data saved");
      })
    .fail((error) => {
        console.log("error: ", error);
    });
  }


}
