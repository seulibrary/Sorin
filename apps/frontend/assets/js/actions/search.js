import Constants from "../constants"
import { apiUrl, parseJSON } from "../utils"

export const search = (query, url, searchFilters = {}) => (dispatch) => {
    // Toggles which "tab/section" is auto selected when results are returned
    if (searchFilters.hasOwnProperty("preSearchType")) {
        dispatch(switchView({
            view: searchFilters.preSearchType
        }))
    }
    
    dispatch({
        type: Constants.SEARCH_LOADING
    })

    fetch(apiUrl + "/api/search" + url, {
        method: "GET",
        credentials: "include"
    }).then(parseJSON)
    .then((payload) => {
        dispatch({
            type: Constants.SEARCH_RESULTS,
            payload: payload,
        })

        dispatch({
            type: Constants.UPDATE_SEARCH_OFFSET
        })
    })
}

export const searchAppend = (query, url, searchFilters, type) => (dispatch) => {
        dispatch({
            type: Constants.SEARCH_LOADING
        })

        fetch(apiUrl + "/api/search" + url, {
            method: "GET",
            credentials: "include"
        }).then(parseJSON)
        .then((payload) => {
            switch (type) {
                case "catalog":
                    dispatch({
                        type: Constants.APPEND_CATALOG_RESULTS,
                        payload: payload.catalogs,
                    })
    
                    break
                case "users":
                    dispatch({
                        type: Constants.APPEND_USER_RESULTS,
                        payload: payload.users,
                    })
    
                    break
                case "collections":
                    dispatch({
                        type: Constants.APPEND_COLLECTION_RESULTS,
                        payload: payload.collections,
                    })
    
                    break
                default:
                    return false
            }
    
            dispatch({
                type: Constants.UPDATE_SEARCH_OFFSET
            })
        })
}

export const setFilters = (payload) => {
    return (dispatch) => {
        dispatch({
            type: Constants.SET_SEARCH_FILTERS,
            payload: payload
        })
    }
}

export const setQuery = (payload) => {
    return (dispatch) => {
        dispatch({
            type: Constants.SEARCH_QUERY_FIELD,
            payload: payload
        })
    }
}

export const searchReset = () => {
    return (dispatch) => {
        dispatch({
            type: Constants.SEARCH_HARD_RESET
        })
        
        dispatch({
            type: Constants.SEARCH_FILTERS_HARD_RESET
        })
    }
}

export const switchView = (payload) => {
    if (payload.view) {
        return (dispatch) => {
            dispatch({
                type: Constants.SWITCH_SEARCH_VIEW,
                payload: payload
            })
        }
    }
}