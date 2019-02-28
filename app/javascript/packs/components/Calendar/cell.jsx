import React, { Component }   from 'react';
import dateFns from 'date-fns';

class Cell extends Component {
  handleClickedDay = () => {
    this.props.clickDay(this.props.day, this.props.events);
  }

  render() {
    return (
      <div
        className={`col cell ${this.props.disabled}`}
        onClick={this.handleClickedDay}
        ref={this.props.refay}
      >
        <span className="number">{this.props.formattedDate}</span>
        <div className="cell-event-title">
          <ul>
            {this.props.events.map((event) => {
              if (event) {
                let attrs = event.data.attributes;
                let time = dateFns.format(
                  new Date(attrs.starting),
                  "h:mmA"
                )
                let name = attrs.name;
                return <li key={event.data.id}>{time} {name}</li>
              }
            })}
          </ul>
        </div>
      </div>
    );
  }
}

export default Cell;
