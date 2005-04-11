
/*
 Copyright (C) 2000-2004 StatPro Italia srl

 This file is part of QuantLib, a free-software/open-source library
 for financial quantitative analysts and developers - http://quantlib.org/

 QuantLib is free software: you can redistribute it and/or modify it under the
 terms of the QuantLib license.  You should have received a copy of the
 license along with this program; if not, please email quantlib-dev@lists.sf.net
 The license is also available online at http://quantlib.org/html/license.html

 This program is distributed in the hope that it will be useful, but WITHOUT
 ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 FOR A PARTICULAR PURPOSE.  See the license for more details.
*/

#ifndef quantlib_date_i
#define quantlib_date_i

%include common.i
%include types.i
%include stl.i

%{
using QuantLib::Day;
using QuantLib::Year;
%}

typedef Integer Day;
typedef Integer Year;


// typemap weekdays to corresponding strings

%{
using QuantLib::Weekday;

Weekday weekdayFromString(std::string s) {
    s = QuantLib::lowercase(s);
    if (s == "sun" || s == "sunday")
        return QuantLib::Sunday;
    else if (s == "mon" || s == "monday")
        return QuantLib::Monday;
    else if (s == "tue" || s == "tuesday")
        return QuantLib::Tuesday;
    else if (s == "wed" || s == "wednesday")
        return QuantLib::Wednesday;
    else if (s == "thu" || s == "thursday")
        return QuantLib::Thursday;
    else if (s == "fri" || s == "friday")
        return QuantLib::Friday;
    else if (s == "sat" || s == "saturday")
        return QuantLib::Saturday;
    else
        QL_FAIL("unknown weekday");
}

std::string stringFromWeekday(Weekday w) {
    switch (w) {
      case QuantLib::Sunday:    return "Sunday";
      case QuantLib::Monday:    return "Monday";
      case QuantLib::Tuesday:   return "Tuesday";
      case QuantLib::Wednesday: return "Wednesday";
      case QuantLib::Thursday:  return "Thursday";
      case QuantLib::Friday:    return "Friday";
      case QuantLib::Saturday:  return "Saturday";
      default:                  QL_FAIL("unknown weekday");
    }
}
%}

MapToString(Weekday,weekdayFromString,stringFromWeekday);


// typemap months to corresponding numbers

%{
using QuantLib::Month;
%}

MapToInteger(Month);


// typemap time units to corresponding strings

%{
using QuantLib::TimeUnit;

TimeUnit timeunitFromString(std::string s) {
    s = QuantLib::lowercase(s);
    if (s == "d" || s == "day" || s == "days")
        return QuantLib::Days;
    else if (s == "w" || s == "week" || s == "weeks")
        return QuantLib::Weeks;
    else if (s == "m" || s == "month" || s == "months")
        return QuantLib::Months;
    else if (s == "y" || s == "year" || s == "years")
        return QuantLib::Years;
    else
        QL_FAIL("unknown time unit");
}

std::string stringFromTimeunit(TimeUnit u) {
    switch (u) {
      case QuantLib::Days:   return "days";
      case QuantLib::Weeks:  return "weeks";
      case QuantLib::Months: return "months";
      case QuantLib::Years:  return "years";
      default:               QL_FAIL("unknown time unit");
    }
}
%}

MapToString(TimeUnit,timeunitFromString,stringFromTimeunit);


// typemap frequencies to corresponding numbers

%{
using QuantLib::Frequency;
%}

MapToInteger(Frequency);

// time period

%{
using QuantLib::Period;
using QuantLib::PeriodParser;
%}

class Period {
    #if defined(SWIGMZSCHEME) || defined(SWIGGUILE)
    %rename(">string")        __str__;
    #endif
  public:
    Period(Integer n, TimeUnit units);
    Integer length() const;
    TimeUnit units() const;
    %extend {
        Period(const std::string& str) {
            return new Period(PeriodParser::parse(str));
        }
        std::string __str__() {
            std::ostringstream out;
            out << *self;
            return out.str();
        }
        std::string __repr__() {
            std::ostringstream out;
            out << "Period(\"" << QuantLib::io::short_period(*self) << "\")";
            return out.str();
        }
        int __cmp__(const Period& other) {
            if (*self < other)
                return -1;
            if (*self == other)
                return 0;
            return 1;
        }
    }
};

namespace std {
    %template(PeriodVector) vector<Period>;
}



%{
using QuantLib::Date;
using QuantLib::DateParser;
%}

#if defined(SWIGRUBY)
%mixin Date "Comparable";
#endif
class Date {
    #if defined(SWIGRUBY)
    %rename("isLeap?")        isLeap;
    %rename("isEOM?")         isEOM;
    #elif defined(SWIGMZSCHEME) || defined(SWIGGUILE)
    %rename("day-of-month")   dayOfMonth;
    %rename("day-of-year")    dayOfYear;
    %rename("weekday-number") weekdayNumber;
    %rename("serial-number")  serialNumber;
    %rename("is-leap?")       isLeap;
    %rename("min-date")       minDate;
    %rename("max-date")       maxDate;
    %rename("todays-date")    todaysDate;
    %rename("end-of-month")   endOfMonth;
    %rename("is-eom?")        isEOM;
    %rename(">string")        __str__;
    #endif
  public:
    Date();
    Date(Day d, Month m, Year y);
    Date(BigInteger serialNumber);
    // access functions
    Weekday weekday() const;
    Day dayOfMonth() const;
    Day dayOfYear() const;        // one-based
    Month month() const;
    Year year() const;
    BigInteger serialNumber() const;
    // static methods
    static bool isLeap(Year y);
    static Date minDate();
    static Date maxDate();
    static Date todaysDate();
    static Date endOfMonth(const Date&);
    static bool isEOM(const Date&);
    #if defined(SWIGPYTHON) || defined(SWIGRUBY)
    Date operator+(BigInteger days) const;
    Date operator-(BigInteger days) const;
    Date operator+(const Period&) const;
    Date operator-(const Period&) const;
    #endif
    %extend {
        Date(const std::string& str, const std::string& fmt) {
            return new Date(DateParser::parse(str,fmt));
        }
        Integer weekdayNumber() {
            return int(self->weekday());
        }
        std::string __str__() {
            std::ostringstream out;
            out << *self;
            return out.str();
        }
        std::string __repr__() {
            std::ostringstream out;
            out << "Date(" << self->dayOfMonth() << ","
                << int(self->month()) << "," << self->year() << ")";
            return out.str();
        }
        std::string ISO() {
            std::ostringstream out;
            out << QuantLib::io::iso_date(*self);
            return out.str();
        }
        #if defined(SWIGPYTHON) || defined(SWIGRUBY)
        BigInteger operator-(const Date& other) {
            return *self - other;
        }
        int __cmp__(const Date& other) {
            if (*self < other)
                return -1;
            else if (*self == other)
                return 0;
            else
                return 1;
        }
        #endif
        #if defined(SWIGPYTHON)
        bool __nonzero__() {
            return (*self != Date());
        }
        int __hash__() {
            return self->serialNumber();
        }
        #endif
        #if defined(SWIGRUBY)
        Date succ() {
            return *self + 1;
        }
        #endif
        #if defined(SWIGMZSCHEME) || defined(SWIGGUILE)
        Date advance(Integer n, TimeUnit units) {
            return *self + n*units;
        }
        #endif
    }
};

#if defined(SWIGPYTHON)
%pythoncode %{
Date._old___add__ = Date.__add__
Date._old___sub__ = Date.__sub__
def Date_new___add__(self,x):
    if type(x) is tuple and len(x) == 2:
        return self._old___add__(Period(x[0],x[1]))
    else:
        return self._old___add__(x)
def Date_new___sub__(self,x):
    if type(x) is tuple and len(x) == 2:
        return self._old___sub__(Period(x[0],x[1]))
    else:
        return self._old___sub__(x)
Date.__add__ = Date_new___add__
Date.__sub__ = Date_new___sub__
%}
#endif

namespace std {
    %template(DateVector) vector<Date>;
}

#if defined(SWIGMZSCHEME) || defined(SWIGGUILE)
%rename("Date=?")  Date_equal;
%rename("Date<?")  Date_less;
%rename("Date<=?") Date_less_equal;
%rename("Date>?")  Date_greater;
%rename("Date>=?") Date_greater_equal;
%inline %{
    // difference - comparison
    BigInteger Date_days_between(const Date& d1, const Date& d2) {
        return d2-d1;
    }
    bool Date_equal(const Date& d1, const Date& d2) {
        return d1 == d2;
    }
    bool Date_less(const Date& d1, const Date& d2) {
        return d1 < d2;
    }
    bool Date_less_equal(const Date& d1, const Date& d2) {
        return d1 <= d2;
    }
    bool Date_greater(const Date& d1, const Date& d2) {
        return d1 > d2;
    }
    bool Date_greater_equal(const Date& d1, const Date& d2) {
        return d1 >= d2;
    }
%}
#endif


#endif
