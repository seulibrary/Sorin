import Constants from "../constants"

const year = (new Date()).getFullYear()

const initialState = {
    query: "",
    searchResults: {},
    searchOffset: 0,
    searchLoading: false,
    searchView: "catalog"
}

const search = (state = initialState, action) => {
    switch (action.type) {
    case Constants.SEARCH:
        return {
            ...state,
            query: action.payload
        }
    case Constants.SEARCH_SET_CHANNEL:
        return {
            ...state,
            searchChannel: action.channel
        }
    case Constants.SEARCH_REMOVE_CHANNEL:
        return {
            ...state,
            searchChannel: {}
        }
    case Constants.SEARCH_LOADING:
        return {
            ...state,
            searchLoading: true,
        }
    case Constants.SWITCH_SEARCH_VIEW:
        return {
            ...state,
            searchView: action.payload.view
        }
    case Constants.SEARCH_RESULTS:
        return {
            ...state,
            searchResults: action.payload,
            searchLoading: false
        }
    case Constants.APPEND_CATALOG_RESULTS:
        return {
            ...state,
            searchResults: {...state.searchResults, catalogs: { ...state.searchResults.catalogs, results: state.searchResults.catalogs.results.concat(action.payload.results)}},
            searchLoading: false,
        }
    case Constants.APPEND_USER_RESULTS:
        return {
            ...state,
            searchResults: {...state.searchResults, users: { ...state.searchResults.users, results: state.searchResults.users.results.concat(action.payload.results)}},
            searchLoading: false,
        }
    case Constants.APPEND_COLLECTION_RESULTS:
        return {
            ...state,
            searchResults: {...state.searchResults, collections: { ...state.searchResults.collections, results: state.searchResults.collections.results.concat(action.payload.results)}},
            searchOffset: state.searchOffset + 25,
            searchLoading: false,
        }
    case Constants.UPDATE_SEARCH_OFFSET:
        return {
            ...state,
            searchOffset: state.searchOffset + 25
        }
    case Constants.SET_SEARCH_OFFSET:
        return {
            ...state,
            searchOffset: action.payload
        }
    case Constants.RESET_SEARCH_OFFSET:
        return {
            ...state,
            searchOffset: 0
        }
    case Constants.SEARCH_RESET:
        return {
            query: state.query,
            searchChannel: state.searchChannel,
            searchResults: {},
            searchOffset: 0,
            searchLoading: false,
            searchView: "catalog"
        }
    case Constants.SEARCH_HARD_RESET:
        return {...initialState, searchChannel: state.searchChannel}
    default:
        return state
    }
}

export default search