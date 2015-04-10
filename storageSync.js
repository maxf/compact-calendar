const backendUrl = 'http://localhost:8080';

export default class StorageSync {

  constructor(keys) {
    this.keys = keys;
  }


  sync() {

    for (let key of this.keys) {

    // for each key, we should check localstorage.key and server.key and take the most recent
    // instead, start simple and get all from the server



      console.log(key);
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
//  saveToServer() {
//    $.post(backendUrl + '/post',
//      {calendarData: JSON.stringify({markedDays: this.markedDays, weekNotes: this.weekNotes})},
//      (data) => {
//        console.log("data saved");
//      })
//    .fail((error) => {
//        console.log("error: ", error);
//    });
//  }


}

