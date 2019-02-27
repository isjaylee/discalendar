import 'regenerator-runtime/runtime'
import { combineReducers }        from 'redux';
import CalendarsReducer           from './Calendar';

const rootReducer = combineReducers({
  calendar: CalendarsReducer
});

export default rootReducer;
