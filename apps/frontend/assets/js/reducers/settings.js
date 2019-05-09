import Constants from "../constants"

const initialState = {
    settings: {}
}

const settings = (state = initialState, action) => {
    switch (action.type) {
    case Constants.GET_SITE_SETTINGS:
        return {
            ...state,
            ...action.payload
        }
    default:
        return state
    }
}

export default settings