import React from "react";
import dateFns from "date-fns";

class Header extends React.Component {
  state = {
    dateFormat: 'MMMM YYYY'
  };

  handleNextMonth = () => {
    this.props.setMonth(dateFns.addMonths(this.props.currentMonth, 1));
  };

  handlePrevMonth = () => {
    this.props.setMonth(dateFns.subMonths(this.props.currentMonth, 1));
  };

  render() {
    return (
      <div className="header row flex-middle">
        <div className="col col-start">
          <div className="icon" onClick={this.handlePrevMonth}>
            chevron_left
          </div>
        </div>
        <div className="col col-center">
          <span>{dateFns.format(this.props.currentMonth, this.state.dateFormat)}</span>
        </div>
        <div className="col col-end" onClick={this.handleNextMonth}>
          <div className="icon">chevron_right</div>
        </div>
      </div>
    );
  }
}

export default Header;