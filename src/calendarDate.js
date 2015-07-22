export default class CalendarDate { // Date can't be subclassed :(
  constructor(...date) {
    this.date = new Date(...date);
  }

  setToTomorrow() { return this._addDays(1); }
  setToNextWeek() { return this._addDays(7); }
  setToYesterday() { return this._addDays(-1); }
  setToPrevWeek() { return this._addDays(-7); }
  setToNextDays(numDays) { return this._addDays(numDays); }

  nextWeek() { return this.clone().setToNextWeek(); }
  nextDays(numDays) { return this.clone().setToNextDays(numDays); }
  clone() { return new CalendarDate(this.date); }

  previousMonday() {
    var newDate = this.clone();

    while (newDate.date.getDay() !== 1) {
      newDate.setToYesterday();
    }
    return newDate;
  }

  getDate() { return this.date.getDate(); }
  getMonth() { return this.date.getMonth(); }
  getFullYear() { return this.date.getFullYear(); }
  getTime() { return this.date.getTime(); }
  toString() { return this.date.toString(); }

  /* private */

  _addDays(numDays) {
    this.date.setTime(this.date.getTime()+numDays*24*3600*1000);
    return this;
  }
}
