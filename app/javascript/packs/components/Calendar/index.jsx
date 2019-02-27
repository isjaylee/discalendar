import React from "react";
import { connect } from 'react-redux';
import { bindActionCreators }     from 'redux';
import { fetchCalendars } from '../../actions/Calendar'
import dateFns from "date-fns";

import Header from '../Calendar/Header';

class Calendar extends React.Component {
  state = {
    currentMonth: new Date(),
    selectedDate: new Date()
  };

  componentDidMount() {
    this.props.fetchCalendars()
  }

  renderDays() {
    const dateFormat = "dddd";
    const days = [];

    let startDate = dateFns.startOfWeek(this.state.currentMonth);

    for (let i = 0; i < 7; i++) {
      days.push(
        <div className="col col-center" key={i}>
          {dateFns.format(dateFns.addDays(startDate, i), dateFormat)}
        </div>
      );
    }

    return <div className="days row">{days}</div>;
  }

  renderCells() {
    const { currentMonth, selectedDate } = this.state;
    const monthStart = dateFns.startOfMonth(currentMonth);
    const monthEnd = dateFns.endOfMonth(monthStart);
    const startDate = dateFns.startOfWeek(monthStart);
    const endDate = dateFns.endOfWeek(monthEnd);

    const dateFormat = "D";
    const rows = [];

    let days = [];
    let day = startDate;
    let formattedDate = "";

    while (day <= endDate) {
      for (let i = 0; i < 7; i++) {
        formattedDate = dateFns.format(day, dateFormat);
        const cloneDay = day;
        days.push(
          <div
            className={`col cell ${
              !dateFns.isSameMonth(day, monthStart)
                ? "disabled"
                : dateFns.isSameDay(day, selectedDate) ? "selected" : ""
            }`}
            key={day}
            onClick={() => this.onDateClick(dateFns.parse(cloneDay))}
          >
            <span className="number">{formattedDate}</span>
            <div className="cell-event-title">
              <ul>
                <li>9:00PM Raid</li>
                <li>10:00PM Nightfall</li>
                <li>10:00PM Nightfall</li>
              </ul>
            </div>
          </div>
        );
        day = dateFns.addDays(day, 1);
      }
      rows.push(
        <div className="row" key={day}>
          {days}
        </div>
      );
      days = [];
    }
    return <div className="body">{rows}</div>;
  }

  onDateClick = day => {
    this.setState({
      selectedDate: day
    });
  };

  setMonth = (month) => {
    this.setState({
      currentMonth: month
    });
  };

  render() {
    return (
      <div>
        <div className="sidebar">
          <div className="sidebar-header">
            <p>Calendars</p>
          </div>
          <ul>
            <li>
              <p>Hello</p>
            </li>
          </ul>
        </div>
        <div className="calendar">
          <Header
            currentMonth={this.state.currentMonth}
            setMonth={this.setMonth}
          />
          {this.renderDays()}
          {this.renderCells()}
        </div>
      </div>
    );
  }
}

const mapStateToProps = state => {
  return { calendars: state.calendar };
};

export default connect(
  mapStateToProps,
  { fetchCalendars }
)(Calendar);