import Constants from "../constants"
import { apiUrl, parseJSON } from "../utils"

// This is used for when looking at single collections via the permalink view.

export const getCollection = (url) => (dispatch) => {

    dispatch({
        type: Constants.GETTING_COLLECTION_BY_URL
    })

    fetch(apiUrl + "/api/collection/" + url, {
        method: "GET",
        credentials: "same-origin"
    }).then(parseJSON)
        .then((json) => {
            dispatch({
                type: Constants.GET_COLLECTION_BY_URL,
                payload: json
            })
        })
}
