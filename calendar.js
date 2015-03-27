"use strict";

var _bind = Function.prototype.bind;

var _createClass = (function () { function defineProperties(target, props) { for (var key in props) { var prop = props[key]; prop.configurable = true; if (prop.value) prop.writable = true; } Object.defineProperties(target, props); } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; })();

var _classCallCheck = function (instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } };

var CalendarDate = (function () {
  // Date can't be subclassed :(

  function CalendarDate() {
    for (var _len = arguments.length, date = Array(_len), _key = 0; _key < _len; _key++) {
      date[_key] = arguments[_key];
    }

    _classCallCheck(this, CalendarDate);

    this.date = new (_bind.apply(Date, [null].concat(date)))();
  }

  _createClass(CalendarDate, {
    setToTomorrow: {
      value: function setToTomorrow() {
        return this._addDays(1);
      }
    },
    setToNextWeek: {
      value: function setToNextWeek() {
        return this._addDays(7);
      }
    },
    setToYesterday: {
      value: function setToYesterday() {
        return this._addDays(-1);
      }
    },
    setToPrevWeek: {
      value: function setToPrevWeek() {
        return this._addDays(-7);
      }
    },
    nextWeek: {
      value: function nextWeek() {
        return this.clone().setToNextWeek();
      }
    },
    clone: {
      value: function clone() {
        return new CalendarDate(this.date);
      }
    },
    previousMonday: {
      value: function previousMonday() {
        var newDate = this.clone();

        while (newDate.date.getDay() !== 1) {
          newDate.setToYesterday();
        }
        return newDate;
      }
    },
    getDate: {
      value: function getDate() {
        return this.date.getDate();
      }
    },
    getMonth: {
      value: function getMonth() {
        return this.date.getMonth();
      }
    },
    getFullYear: {
      value: function getFullYear() {
        return this.date.getFullYear();
      }
    },
    toString: {
      value: function toString() {
        return this.date.toString();
      }
    },
    _addDays: {

      /* private */

      value: function _addDays(numDays) {
        this.date.setTime(this.date.getTime() + numDays * 24 * 3600 * 1000);
        return this;
      }
    }
  });

  return CalendarDate;
})();

var Calendar = (function () {
  function Calendar() {
    var year = arguments[0] === undefined ? new Date().getFullYear() : arguments[0];

    _classCallCheck(this, Calendar);

    this.year = year;
    this.months = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
    this.daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  }

  _createClass(Calendar, {
    toHtml: {
      value: function toHtml() {
        var calHtml = ["<table><thead><tr><th>Month</th>"];
        var day = new CalendarDate(this.year, 0, 1, 12); /* new year's day at midday */

        // populate header with labels for days of week
        for (var dow = 0; dow < 7; dow++) {
          calHtml.push("<th>" + this.daysOfWeek[dow].substr(0, 2) + "</th>");
        }

        calHtml.push("</thead></tbody>");

        day = day.previousMonday();
        while (day.getFullYear() <= this.year) {

          var isFirstWeekInMonth = day.getDate() > day.nextWeek().getDate();
          var firstColText = isFirstWeekInMonth ? this.months[day.getMonth()] : "";
          var week = [];

          for (var dow = 0; dow < 7; dow++) {
            var classAttr = undefined;
            var date = day.getDate();
            if (isFirstWeekInMonth) {
              if (date >= 23) {
                classAttr = "beforeFirst"; // this day is before the first day of the next month
              } else if (date === 1) {
                classAttr = "firstDayOfMonth"; // this day is the first day of the next month
              } else {
                classAttr = "afterFirst"; // this day is after the first day of the next month
              }
            }
            week.push("<td " + (classAttr ? "class=\"" + classAttr + "\"" : "") + ">" + date + "</td>");

            day.setToTomorrow();
          }
          calHtml.push("<tr><td " + (isFirstWeekInMonth ? "class=\"newMonth\"" : "") + ">" + firstColText + "</td>" + week.join("") + "</tr>");
        }

        calHtml.push("</tbody></table>");

        return calHtml.join("");
      }
    }
  });

  return Calendar;
})();
