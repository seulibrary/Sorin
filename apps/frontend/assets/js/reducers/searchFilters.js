import Constants from "../constants"

const initialState = {
    searchFilters: {}
}

const searchFilters = (state = initialState, action) => {
    switch (action.type) {
    case Constants.SEARCH_FILTER_SETTING:
        return {
            ...state,
            [action.propertyName]: action.payload
        }
    case Constants.SET_SEARCH_FILTERS:
        return {
            ...state,
            searchFilters: {...state.searchFilters, ...action.payload}
        }
    case Constants.SEARCH_FILTERS_HARD_RESET:
        return initialState
    default:
        return state
    }
}

export default searchFilters