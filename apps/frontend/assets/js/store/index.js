import { 
    createStore, 
    applyMiddleware, 
    compose 
} from "redux"
import { routerMiddleware } from "react-router-redux"
import thunk from "redux-thunk"
import { createBrowserHistory } from "history"
import rootReducer from "../reducers"
import { composeWithDevTools } from "redux-devtools-extension"

export const history = createBrowserHistory()

const initialState = {}
const enhancers = []
const middleware = [
    thunk,
    routerMiddleware(history)

]

const composedEnhancers = (ENV_MODE === "development") ? compose(
          composeWithDevTools(
              applyMiddleware(
                  ...middleware),
              ...enhancers
          )) : compose(
              applyMiddleware(
                  ...middleware),
              ...enhancers
          )

const store = createStore(
    rootReducer,
    initialState,
    composedEnhancers
)

export default store
