import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import { createStore, applyMiddleware } from 'redux';
import thunk from 'redux-thunk';
import rootReducer                      from './reducers';
import { BrowserRouter as Router, Route, Switch, Redirect } from 'react-router-dom';

import Calendar from './components/Calendar';

const store = createStore(rootReducer, applyMiddleware(thunk));

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Provider store={store}>
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
            <Switch>
              <Route path="/" component={Calendar} />
            </Switch>
          </main>
        </div>
      </Router>
    </Provider>
    , document.getElementById('discalendar-app'),
  )
});