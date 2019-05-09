import Constants from "../constants"
import { Socket } from "../../../../../deps/phoenix"

export const joinSearchChannel = () => {
    return (dispatch) => {
        const socket = new Socket("/socket", {
            params: {
                token: window.userToken
            }
        })

        socket.connect()

        const channel = socket.channel("search:" + window.userToken)

        if (channel.state != "joined") {
            channel.join().receive("ok", () => {
                dispatch({
                    type: Constants.SEARCH_SET_CHANNEL,
                    channel: channel
                })
            })
        }

        channel.on("search", payload => {
            dispatch({
                type: Constants.SEARCH_RESULTS,
                payload: payload,
            })

            dispatch({
                type: Constants.UPDATE_SEARCH_OFFSET
            })
        })

        channel.on("load_more_catalog_results", payload => {
            dispatch({
                type: Constants.APPEND_CATALOG_RESULTS,
                payload: payload,
            })

            dispatch({
                type: Constants.UPDATE_SEARCH_OFFSET
            })
        })

        channel.on("load_more_user_results", payload => {
            dispatch({
                type: Constants.APPEND_USER_RESULTS,
                payload: payload,
            })

            dispatch({
                type: Constants.UPDATE_SEARCH_OFFSET
            })
        })

        channel.on("load_more_collection_results", payload => {
            
            
            dispatch({
                type: Constants.APPEND_COLLECTION_RESULTS,
                payload: payload,
            })

            dispatch({
                type: Constants.UPDATE_SEARCH_OFFSET
            })
        })
    }
}

export const leaveSearchChannel = (channel) => {
    return (dispatch) => {
        channel.leave()

        dispatch({
            type: Constants.SEARCH_REMOVE_CHANNEL
        })
    }
}

export const search = (channel, query, searchObject, searchFilters) => {
    return (dispatch) => {
        if (searchFilters.hasOwnProperty("preSearchType")) {
            dispatch(switchView({
                view: searchFilters.preSearchType
            }))
        }
        
        dispatch({
            type: Constants.SEARCH_LOADING
        })
        
        // Make sure offset is reset to 0 in redux
        dispatch({
            type: Constants.RESET_SEARCH_OFFSET
        })

        channel.push("search", {
            query: query,
            limit: 25,
            offset: 0,
            filters: searchFilters
        })
    }
}

export const searchAppend = (channel, query, searchObject, searchFilters, type) => {
    return (dispatch) => {
        dispatch({
            type: Constants.SEARCH_LOADING
        })

        switch (type) {
        case "catalog":
            channel.push("load_more_catalog_results", {
                query: query,
                limit: 25,
                offset: searchObject.searchOffset,
                filters: searchFilters
            })
            break
        case "users":
            channel.push("load_more_user_results", {
                query: query,
                limit: 25,
                offset: searchObject.searchOffset,
                filters: searchFilters
            })
            break
        case "collections":
            channel.push("load_more_collection_results", {
                query: query,
                limit: 25,
                offset: searchObject.searchOffset,
                filters: searchFilters
            })
            break
        default:
            return false
        }
    }
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
            type: Constants.SEARCH_HARD_RESET,
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