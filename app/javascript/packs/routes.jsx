import React from 'react'
import {
  BrowserRouter as Router,
  Route,
} from 'react-router-dom'

import Calendar from './components/Calendar';

const App = (props) => (
  <Router>
    <div>
      <header>
        <div id="logo">
          <span className="icon">date_range</span>
          <span>
            Dis<b>calendar</b>
          </span>
        </div>
      </header>
      <main>
        <Route exact path='/' component={Calendar} />
      </main>
    </div>
  </Router>
)

export default App;
